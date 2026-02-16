"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createParent = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const PARENT_EMAIL_DOMAIN = "polenacademy.com";
function toParentEmailLocalPart(firstName, lastName) {
    var _a;
    const combined = `${(firstName || "").trim()}${(lastName || "").trim()}`.toLowerCase();
    const map = {
        "ğ": "g", "ü": "u", "ş": "s", "ö": "o", "ç": "c", "ı": "i", "İ": "i",
    };
    let out = "";
    for (const c of combined) {
        out += (_a = map[c]) !== null && _a !== void 0 ? _a : c;
    }
    out = out.replace(/[^a-z0-9]/g, "");
    return out || "user";
}
function generatePassword(length = 12) {
    const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let result = "";
    for (let i = 0; i < length; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}
/**
 * Veli kullanıcısı oluşturur. Firestore'a uid, parentName, parentSurname,
 * email, coachId, studentId, role, createdAt yazar.
 * Email: {firstName}{lastName}@polenacademy.com (no prefix)
 * If studentId is provided, the student document is updated with parentId and hasParent.
 */
exports.createParent = functions.region("us-central1").https.onCall(async (data, context) => {
    var _a;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Coach must be logged in.");
    }
    const coachUid = context.auth.uid;
    const { parentName, parentSurname, coachId = "", studentId = "", } = data;
    if (!parentName || !parentSurname) {
        throw new functions.https.HttpsError("invalid-argument", "parentName and parentSurname are required.");
    }
    const db = admin.firestore();
    const auth = admin.auth();
    const coachDoc = await db.collection("Users").doc(coachUid).get();
    const coachRole = (_a = coachDoc.data()) === null || _a === void 0 ? void 0 : _a.role;
    if (coachRole !== "coach") {
        throw new functions.https.HttpsError("permission-denied", "Only coaches can create parents.");
    }
    const baseLocal = toParentEmailLocalPart(parentName, parentSurname);
    let localPart = baseLocal;
    let suffix = 0;
    let email = `${localPart}@${PARENT_EMAIL_DOMAIN}`;
    let usersSnap = await db.collection("Users").where("email", "==", email).limit(1).get();
    while (!usersSnap.empty) {
        suffix++;
        localPart = `${baseLocal}${suffix}`;
        email = `${localPart}@${PARENT_EMAIL_DOMAIN}`;
        usersSnap = await db.collection("Users").where("email", "==", email).limit(1).get();
    }
    const password = generatePassword(12);
    const userRecord = await auth.createUser({
        email,
        password,
        emailVerified: false,
    });
    const uid = userRecord.uid;
    const finalCoachId = coachId || coachUid;
    const finalStudentId = studentId || "";
    await db.collection("Users").doc(uid).set({
        uid,
        parentName: parentName.trim(),
        parentSurname: parentSurname.trim(),
        email,
        coachId: finalCoachId,
        studentId: finalStudentId,
        role: "parent",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    if (finalStudentId) {
        await db.collection("Users").doc(finalStudentId).update({
            parentId: uid,
            hasParent: true,
        });
    }
    return { email, password, uid };
});
//# sourceMappingURL=createParent.js.map