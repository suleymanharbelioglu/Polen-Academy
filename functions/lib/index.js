"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateUserPassword = exports.deleteStudent = exports.createParent = exports.createStudent = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const STUDENT_EMAIL_DOMAIN = "polenacademy.com";
function toEmailLocalPart(firstName, lastName) {
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
    return out || "student";
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
 * Creates a student user. Writes to Firestore with all Student properties:
 * uid, studentName, studentSurname, email, studentClass, coachId, parentId, progress, role, createdAt.
 */
exports.createStudent = functions.region("us-central1").https.onCall(async (data, context) => {
    var _a;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Coach must be logged in.");
    }
    const coachUid = context.auth.uid;
    const { studentName, studentSurname, studentClass, coachId = "", parentId = "", progress = 0, focusCourseIds = [], } = data;
    if (!studentName || !studentSurname || !studentClass) {
        throw new functions.https.HttpsError("invalid-argument", "studentName, studentSurname and studentClass are required.");
    }
    const db = admin.firestore();
    const auth = admin.auth();
    const coachDoc = await db.collection("Users").doc(coachUid).get();
    const coachRole = (_a = coachDoc.data()) === null || _a === void 0 ? void 0 : _a.role;
    if (coachRole !== "coach") {
        throw new functions.https.HttpsError("permission-denied", "Only coaches can create students.");
    }
    const baseLocal = toEmailLocalPart(studentName, studentSurname);
    let localPart = baseLocal;
    let suffix = 0;
    let email = `${localPart}@${STUDENT_EMAIL_DOMAIN}`;
    let usersSnap = await db.collection("Users").where("email", "==", email).limit(1).get();
    while (!usersSnap.empty) {
        suffix++;
        localPart = `${baseLocal}${suffix}`;
        email = `${localPart}@${STUDENT_EMAIL_DOMAIN}`;
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
    const finalParentId = parentId || "";
    const focusIds = Array.isArray(focusCourseIds)
        ? focusCourseIds.map((id) => String(id)).filter(Boolean)
        : [];
    await db.collection("Users").doc(uid).set({
        uid,
        studentName: studentName.trim(),
        studentSurname: studentSurname.trim(),
        email,
        studentClass: studentClass.trim(),
        coachId: finalCoachId,
        parentId: finalParentId,
        role: "student",
        progress: typeof progress === "number" ? progress : 0,
        hasParent: !!finalParentId,
        focusCourseIds: focusIds,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { email, password, uid };
});
var createParent_1 = require("./createParent");
Object.defineProperty(exports, "createParent", { enumerable: true, get: function () { return createParent_1.createParent; } });
var deleteStudent_1 = require("./deleteStudent");
Object.defineProperty(exports, "deleteStudent", { enumerable: true, get: function () { return deleteStudent_1.deleteStudent; } });
var updateUserPassword_1 = require("./updateUserPassword");
Object.defineProperty(exports, "updateUserPassword", { enumerable: true, get: function () { return updateUserPassword_1.updateUserPassword; } });
//# sourceMappingURL=index.js.map