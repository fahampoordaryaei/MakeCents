import { onSchedule } from "firebase-functions/v2/scheduler";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { Connector, IpAddressTypes, AuthTypes } from "@google-cloud/cloud-sql-connector";
import pg from "pg";

const { Pool } = pg;

const INSTANCE_CONNECTION = "makecents-b0fb9:europe-west1:makecents-b0fb9-database";
const DB_NAME = "makecents-b0fb9-database";
const DB_IAM_USER_RAW = process.env.DB_IAM_USER ?? "";
const DB_IAM_USER = DB_IAM_USER_RAW.replace(/\.gserviceaccount\.com$/, "");
const CODE_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

const createPool = async () => {
    if (!DB_IAM_USER) {
        throw new Error("Missing DB_IAM_USER environment variable.");
    }

    const connector = new Connector();
    const clientOpts = await connector.getOptions({
        instanceConnectionName: INSTANCE_CONNECTION,
        ipType: IpAddressTypes.PUBLIC,
        authType: AuthTypes.IAM,
    });

    const pool = new Pool({
        ...clientOpts,
        database: DB_NAME,
        user: DB_IAM_USER,
        max: 5,
    });

    return { connector, pool };
};

const generateDiscountCode = () => {
    let code = "";
    for (let i = 0; i < 6; i++) {
        const idx = Math.floor(Math.random() * CODE_CHARS.length);
        code += CODE_CHARS[idx];
    }
    return code;
};

export const monthlyBudgetReward = onSchedule(
    {
        schedule: "0 0 1 * *",
        timeZone: "UTC",
        region: "europe-west1",
    },
    async () => {
        const { connector, pool } = await createPool();

        try {
            const now = new Date();
            const prevYear = now.getMonth() === 0 ? now.getFullYear() - 1 : now.getFullYear();
            const prevMonth = now.getMonth() === 0 ? 12 : now.getMonth();
            const monthKey = `${prevYear}-${String(prevMonth).padStart(2, "0")}`;

            const firstDay = `${prevYear}-${String(prevMonth).padStart(2, "0")}-01`;
            const nextMonth = prevMonth === 12 ? 1 : prevMonth + 1;
            const nextYear = prevMonth === 12 ? prevYear + 1 : prevYear;
            const lastDay = `${nextYear}-${String(nextMonth).padStart(2, "0")}-01`;

            const result = await pool.query(`
        SELECT
          u.username,
          u.monthly_budget,
          pb.id AS pb_id,
          pb.total_points,
          COALESCE(SUM(t.amount), 0) AS month_spent
        FROM "user" u
        JOIN points_balance pb ON pb.user_username = u.username
        LEFT JOIN "transaction" t
          ON t.user_username = u.username
          AND t.date >= $1::date
          AND t.date < $2::date
        WHERE u.monthly_budget > 0
          AND (pb.last_budget_reward_month IS NULL OR pb.last_budget_reward_month != $3)
        GROUP BY u.username, u.monthly_budget, pb.id, pb.total_points
        HAVING COALESCE(SUM(t.amount), 0) > 0
          AND COALESCE(SUM(t.amount), 0) < u.monthly_budget
      `, [firstDay, lastDay, monthKey]);

            const REWARD = 100;

            for (const row of result.rows) {
                const newTotal = row.total_points + REWARD;
                await pool.query(`
          UPDATE points_balance
          SET total_points = $1,
              last_budget_reward_month = $2,
              updated_at = NOW()
          WHERE id = $3
        `, [newTotal, monthKey, row.pb_id]);

                console.log(
                    `Awarded ${REWARD} pts to ${row.username} ` +
                    `(spent ${row.month_spent}/${row.monthly_budget}, new total: ${newTotal})`
                );
            }

        } catch (err) {
            console.error("Error in monthlyBudgetReward:", err);
            throw err;
        } finally {
            await pool.end();
            connector.close();
        }
    }
);

export const redeemProduct = onCall(
    {
        region: "europe-west1",
    },
    async (request) => {
        const userId = request.auth?.uid;
        if (!userId) {
            throw new HttpsError("unauthenticated", "You must be signed in.");
        }

        const productId = request.data?.productId;
        if (typeof productId !== "string" || productId.trim().length === 0) {
            throw new HttpsError("invalid-argument", "A valid productId is required.");
        }

        const { connector, pool } = await createPool();
        let client: pg.PoolClient | null = null;
        try {
            client = await pool.connect();
            await client.query("BEGIN");

            const pointsResult = await client.query(
                `
          SELECT id, total_points
          FROM points_balance
          WHERE user_username = $1
          FOR UPDATE
        `,
                [userId]
            );

            if (pointsResult.rowCount === 0) {
                throw new HttpsError(
                    "failed-precondition",
                    "Points balance is not initialized for this user."
                );
            }

            const productResult = await client.query(
                `
          SELECT id, cost, active
          FROM product
          WHERE id = $1
        `,
                [productId.trim()]
            );

            if (productResult.rowCount === 0) {
                throw new HttpsError("not-found", "Product not found.");
            }

            const productRow = productResult.rows[0];
            if (!productRow.active) {
                throw new HttpsError("failed-precondition", "Product is not active.");
            }

            const pointsRow = pointsResult.rows[0];
            const currentPoints = Number(pointsRow.total_points);
            const cost = Number(productRow.cost);

            if (currentPoints < cost) {
                throw new HttpsError("failed-precondition", "Not enough points.");
            }

            const code = generateDiscountCode();
            try {
                await client.query(
                    `
              INSERT INTO redeemed_product (user_username, product_id, code, redeemed_at)
              VALUES ($1, $2, $3, NOW())
            `,
                    [userId, productRow.id, code]
                );
            } catch (err: unknown) {
                const pgErr = err as { code?: string; constraint?: string };
                if (pgErr.code === "23505") {
                    if (pgErr.constraint === "redeemed_product_pkey") {
                        throw new HttpsError(
                            "failed-precondition",
                            "This product has already been redeemed."
                        );
                    }
                    if (pgErr.constraint === "redeemed_product_code_key") {
                        throw new HttpsError("aborted", "Please try redeeming again.");
                    }
                }
                throw err;
            }

            await client.query(
                `
          INSERT INTO points_transaction (user_username, amount, reason, created_at)
          VALUES ($1, $2, $3, NOW())
        `,
                [userId, -cost, `redeem:${productRow.id}`]
            );

            const remainingPoints = currentPoints - cost;
            await client.query(
                `
          UPDATE points_balance
          SET total_points = $1, updated_at = NOW()
          WHERE id = $2
        `,
                [remainingPoints, pointsRow.id]
            );

            await client.query("COMMIT");
            return {
                code,
                cost,
                remainingPoints,
                productId: productRow.id,
            };
        } catch (err) {
            if (client) {
                await client.query("ROLLBACK");
            }
            if (err instanceof HttpsError) {
                throw err;
            }
            console.error("Error in redeemProduct:", err);
            throw new HttpsError("internal", "Could not redeem product.");
        } finally {
            client?.release();
            await pool.end();
            connector.close();
        }
    }
);
