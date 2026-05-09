import { initializeApp, cert } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { readFileSync } from "node:fs";

const serviceAccount = JSON.parse(
    readFileSync(new URL("./service-account.json", import.meta.url), "utf8"),
);

initializeApp({ credential: cert(serviceAccount), projectId: "makecents-b0fb9" });

async function deleteAll() {
    let deleted = 0;
    let nextPageToken = undefined;
    do {
        const page = await getAuth().listUsers(1000, nextPageToken);
        const uids = page.users.map((u) => u.uid);
        if (uids.length) {
            const res = await getAuth().deleteUsers(uids);
            deleted += res.successCount;
            console.log(
                `deleted ${res.successCount} / failed ${res.failureCount} (total deleted: ${deleted})`,
            );
            if (res.failureCount) {
                for (const e of res.errors) console.error(e.error?.message ?? e);
            }
        }
        nextPageToken = page.pageToken;
    } while (nextPageToken);
    console.log(`Done. Total deleted: ${deleted}`);
}

deleteAll().catch((e) => {
    console.error(e);
    process.exit(1);
});