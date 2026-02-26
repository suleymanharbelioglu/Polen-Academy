import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Firestore'da "notifications" koleksiyonuna yeni doküman yazıldığında tetiklenir.
 * Alıcının Users dokümanındaki fcmToken ile FCM (push) bildirimi gönderir.
 * Uygulama kapalıyken veya arka plandayken de cihaza bildirim düşer.
 */
export const sendNotificationOnCreate = functions
  .region("us-central1")
  .runWith({ timeoutSeconds: 30 })
  .firestore.document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const recipientUserId = data?.recipientUserId ?? data?.userId;
    const title = (data?.title as string) ?? "Bildirim";
    const body = (data?.body as string) ?? "";

    if (!recipientUserId || typeof recipientUserId !== "string") {
      functions.logger.warn("sendNotificationOnCreate: missing recipientUserId", {
        notificationId: context.params.notificationId,
      });
      return null;
    }

    const db = admin.firestore();
    const userDoc = await db.collection("Users").doc(recipientUserId).get();
    const fcmToken = userDoc.data()?.fcmToken as string | undefined;

    if (!fcmToken || typeof fcmToken !== "string") {
      functions.logger.info("sendNotificationOnCreate: no fcmToken for user", {
        recipientUserId,
        notificationId: context.params.notificationId,
      });
      return null;
    }

    try {
      await admin.messaging().send({
        token: fcmToken,
        notification: { title, body },
        android: { priority: "high" as const },
        apns: {
          payload: { aps: { sound: "default" } },
        },
      });
      functions.logger.info("FCM sent", {
        recipientUserId,
        notificationId: context.params.notificationId,
      });
    } catch (err) {
      functions.logger.error("FCM send failed", {
        recipientUserId,
        notificationId: context.params.notificationId,
        error: err,
      });
    }

    return null;
  });
