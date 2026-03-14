import { onSchedule } from "firebase-functions/v2/scheduler";
import { Connector, IpAddressTypes, AuthTypes } from "@google-cloud/cloud-sql-connector";
import pg from "pg";

const { Pool } = pg;

const INSTANCE_CONNECTION = "makecents-b0fb9:europe-west1:makecents-b0fb9-database";
const DB_NAME = "makecents-b0fb9-database";

export const monthlyBudgetReward = onSchedule(
    {
        schedule: "0 0 1 * *",
        timeZone: "UTC",
        region: "europe-west1",
    },
    async () => {
        const connector = new Connector();
        const clientOpts = await connector.getOptions({
            instanceConnectionName: INSTANCE_CONNECTION,
            ipType: IpAddressTypes.PUBLIC,
            authType: AuthTypes.IAM,
        });

        const pool = new Pool({
            ...clientOpts,
            database: DB_NAME,
            max: 5,
        });

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

            const REWARD = 50;

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
