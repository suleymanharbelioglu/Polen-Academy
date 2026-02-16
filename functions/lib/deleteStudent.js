"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteStudent = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
/**
 * Deletes a student and, if present, their parent:
 * - Deletes parent's Firebase Auth account and Users document (when student has parent).
 * - Deletes student's Firebase Auth account and Users document.
 * Callable by coach only; student must belong to the coach.
 */
exports.deleteStudent = functions.region("us-central1").https.onCall(async (data, context) => {
    var _a, _b, _c;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Coach must be logged in.");
    }
    const coachUid = context.auth.uid;
    const { studentId } = data;
    if (!studentId || typeof studentId !== "string") {
        throw new functions.https.HttpsError("invalid-argument", "studentId is required.");
    }
    const db = admin.firestore();
    const auth = admin.auth();
    const coachDoc = await db.collection("Users").doc(coachUid).get();
    if (((_a = coachDoc.data()) === null || _a === void 0 ? void 0 : _a.role) !== "coach") {
        throw new functions.https.HttpsError("permission-denied", "Only coaches can delete students.");
    }
    const studentRef = db.collection("Users").doc(studentId);
    const studentSnap = await studentRef.get();
    if (!studentSnap.exists) {
        throw new functions.https.HttpsError("not-found", "Student not found.");
    }
    const studentData = studentSnap.data();
    const studentCoachId = (_b = studentData === null || studentData === void 0 ? void 0 : studentData.coachId) !== null && _b !== void 0 ? _b : "";
    if (studentCoachId !== coachUid) {
        throw new functions.https.HttpsError("permission-denied", "Student does not belong to this coach.");
    }
    const parentId = ((_c = studentData === null || studentData === void 0 ? void 0 : studentData.parentId) !== null && _c !== void 0 ? _c : "");
    if (parentId) {
        try {
            await auth.deleteUser(parentId);
        }
        catch (e) {
            // Parent auth may already be deleted; continue to delete Firestore doc
        }
        try {
            await db.collection("Users").doc(parentId).delete();
        }
        catch (e) {
            // Ignore if already deleted
        }
    }
    try {
        await auth.deleteUser(studentId);
    }
    catch (e) {
        // Student auth may already be deleted
    }
    await studentRef.delete();
    return { success: true };
});
//# sourceMappingURL=deleteStudent.js.map