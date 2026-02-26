"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendNotificationOnCreate = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
/**
 * Firestore'da "notifications" koleksiyonuna yeni doküman yazıldığında tetiklenir.
 * Alıcının Users dokümanındaki fcmToken ile FCM (push) bildirimi gönderir.
 * Uygulama kapalıyken veya arka plandayken de cihaza bildirim düşer.
 */
exports.sendNotificationOnCreate = functions
    .region("us-central1")
    .runWith({ timeoutSeconds: 30 })
    .firestore.document("notifications/{notificationId}")
    .onCreate(async (snap, context) => {
    var _a, _b, _c, _d;
    const data = snap.data();
    const recipientUserId = (_a = data === null || data === void 0 ? void 0 : data.recipientUserId) !== null && _a !== void 0 ? _a : data === null || data === void 0 ? void 0 : data.userId;
    const title = (_b = data === null || data === void 0 ? void 0 : data.title) !== null && _b !== void 0 ? _b : "Bildirim";
    const body = (_c = data === null || data === void 0 ? void 0 : data.body) !== null && _c !== void 0 ? _c : "";
    if (!recipientUserId || typeof recipientUserId !== "string") {
        functions.logger.warn("sendNotificationOnCreate: missing recipientUserId", {
            notificationId: context.params.notificationId,
        });
        return null;
    }
    const db = admin.firestore();
    const userDoc = await db.collection("Users").doc(recipientUserId).get();
    const fcmToken = (_d = userDoc.data()) === null || _d === void 0 ? void 0 : _d.fcmToken;
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
            android: { priority: "high" },
            apns: {
                payload: { aps: { sound: "default" } },
            },
        });
        functions.logger.info("FCM sent", {
            recipientUserId,
            notificationId: context.params.notificationId,
        });
    }
    catch (err) {
        functions.logger.error("FCM send failed", {
            recipientUserId,
            notificationId: context.params.notificationId,
            error: err,
        });
    }
    return null;
});
//# sourceMappingURL=sendNotificationOnCreate.js.map