import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Her gün Türkiye saati 20:00'da çalışır.
 * "scheduled_reminders" koleksiyonunda sendAt <= şu an olan ve henüz gönderilmemiş
 * (sentAt yok) seans hatırlatmalarını bulur, öğrenci ve veliye FCM gönderir.
 */
export const sendSessionReminders = functions
  .region("us-central1")
  .runWith({ timeoutSeconds: 120 })
  .pubsub.schedule("0 20 * * *")
  .timeZone("Europe/Istanbul")
  .onRun(async () => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    const snapshot = await db
      .collection("scheduled_reminders")
      .where("type", "==", "session_reminder")
      .where("sendAt", "<=", now)
      .get();

    const toProcess: admin.firestore.QueryDocumentSnapshot<admin.firestore.DocumentData>[] = [];
    snapshot.docs.forEach((doc) => {
      if (doc.data().sentAt == null) {
        toProcess.push(doc);
      }
    });

    for (const doc of toProcess) {
      const data = doc.data();
      const studentId = data.studentId as string | undefined;
      const parentId = data.parentId as string | undefined;
      const studentName = (data.studentName as string) ?? "Öğrenci";
      const sessionStartTime = (data.sessionStartTime as string) ?? "";
      const sessionDate = data.sessionDate as admin.firestore.Timestamp | undefined;

      let dateStr = "";
      if (sessionDate?.toDate) {
        const d = sessionDate.toDate();
        dateStr = `${d.getDate().toString().padStart(2, "0")}.${(d.getMonth() + 1).toString().padStart(2, "0")}.${d.getFullYear()}`;
      }
      const body = `Yarın ${dateStr} ${sessionStartTime} - ${studentName}`;
      const title = "Seans hatırlatması";

      const userIds: string[] = [];
      if (studentId) userIds.push(studentId);
      if (parentId) userIds.push(parentId);

      for (const uid of userIds) {
        try {
          const userDoc = await db.collection("Users").doc(uid).get();
          const fcmToken = userDoc.data()?.fcmToken as string | undefined;
          if (fcmToken) {
            await admin.messaging().send({
              token: fcmToken,
              notification: { title, body },
              android: { priority: "high" as const },
              apns: { payload: { aps: { sound: "default" } } },
            });
          }
        } catch (err) {
          functions.logger.error("Session reminder FCM failed", { uid, reminderId: doc.id, error: err });
        }
      }

      await doc.ref.update({ sentAt: admin.firestore.FieldValue.serverTimestamp() });
    }

    functions.logger.info("Session reminders run", { processed: toProcess.length });
    return null;
  });
