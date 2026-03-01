"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendSessionReminders = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
/**
 * Her gün Türkiye saati 20:00'da çalışır.
 * "scheduled_reminders" koleksiyonunda sendAt <= şu an olan ve henüz gönderilmemiş
 * (sentAt yok) seans hatırlatmalarını bulur, öğrenci ve veliye FCM gönderir.
 */
exports.sendSessionReminders = functions
    .region("us-central1")
    .runWith({ timeoutSeconds: 120 })
    .pubsub.schedule("0 20 * * *")
    .timeZone("Europe/Istanbul")
    .onRun(async () => {
    var _a, _b, _c;
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const snapshot = await db
        .collection("scheduled_reminders")
        .where("type", "==", "session_reminder")
        .where("sendAt", "<=", now)
        .get();
    const toProcess = [];
    snapshot.docs.forEach((doc) => {
        if (doc.data().sentAt == null) {
            toProcess.push(doc);
        }
    });
    for (const doc of toProcess) {
        const data = doc.data();
        const studentId = data.studentId;
        const parentId = data.parentId;
        const studentName = (_a = data.studentName) !== null && _a !== void 0 ? _a : "Öğrenci";
        const sessionStartTime = (_b = data.sessionStartTime) !== null && _b !== void 0 ? _b : "";
        const sessionDate = data.sessionDate;
        let dateStr = "";
        if (sessionDate === null || sessionDate === void 0 ? void 0 : sessionDate.toDate) {
            const d = sessionDate.toDate();
            dateStr = `${d.getDate().toString().padStart(2, "0")}.${(d.getMonth() + 1).toString().padStart(2, "0")}.${d.getFullYear()}`;
        }
        const body = `Yarın ${dateStr} ${sessionStartTime} - ${studentName}`;
        const title = "Seans hatırlatması";
        const userIds = [];
        if (studentId)
            userIds.push(studentId);
        if (parentId)
            userIds.push(parentId);
        for (const uid of userIds) {
            try {
                const userDoc = await db.collection("Users").doc(uid).get();
                const fcmToken = (_c = userDoc.data()) === null || _c === void 0 ? void 0 : _c.fcmToken;
                if (fcmToken) {
                    await admin.messaging().send({
                        token: fcmToken,
                        notification: { title, body },
                        android: { priority: "high" },
                        apns: { payload: { aps: { sound: "default" } } },
                    });
                }
            }
            catch (err) {
                functions.logger.error("Session reminder FCM failed", { uid, reminderId: doc.id, error: err });
            }
        }
        await doc.ref.update({ sentAt: admin.firestore.FieldValue.serverTimestamp() });
    }
    functions.logger.info("Session reminders run", { processed: toProcess.length });
    return null;
});
//# sourceMappingURL=sendSessionReminders.js.map