"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateUserPassword = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
/**
 * Coach can set a new password for a student or parent that belongs to them.
 * Payload: { userId: string, newPassword: string }
 */
exports.updateUserPassword = functions.region("us-central1").https.onCall(async (data, context) => {
    var _a, _b;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Coach must be logged in.");
    }
    const coachUid = context.auth.uid;
    const { userId, newPassword } = data;
    if (!userId || typeof userId !== "string") {
        throw new functions.https.HttpsError("invalid-argument", "userId is required.");
    }
    if (!newPassword || typeof newPassword !== "string" || newPassword.length < 6) {
        throw new functions.https.HttpsError("invalid-argument", "newPassword is required and must be at least 6 characters.");
    }
    const db = admin.firestore();
    const auth = admin.auth();
    const coachDoc = await db.collection("Users").doc(coachUid).get();
    if (((_a = coachDoc.data()) === null || _a === void 0 ? void 0 : _a.role) !== "coach") {
        throw new functions.https.HttpsError("permission-denied", "Only coaches can update passwords.");
    }
    const userRef = db.collection("Users").doc(userId);
    const userSnap = await userRef.get();
    if (!userSnap.exists) {
        throw new functions.https.HttpsError("not-found", "User not found.");
    }
    const userData = userSnap.data();
    const userCoachId = ((_b = userData === null || userData === void 0 ? void 0 : userData.coachId) !== null && _b !== void 0 ? _b : "");
    if (userCoachId !== coachUid) {
        throw new functions.https.HttpsError("permission-denied", "User does not belong to this coach.");
    }
    await auth.updateUser(userId, { password: newPassword });
    return { success: true };
});
//# sourceMappingURL=updateUserPassword.js.map