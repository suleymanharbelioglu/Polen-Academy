import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Deletes a student and, if present, their parent:
 * - Deletes parent's Firebase Auth account and Users document (when student has parent).
 * - Deletes student's Firebase Auth account and Users document.
 * Callable by coach only; student must belong to the coach.
 */
export const deleteStudent = functions.region("us-central1").https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Coach must be logged in.");
  }

  const coachUid = context.auth.uid;
  const { studentId } = data;

  if (!studentId || typeof studentId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "studentId is required."
    );
  }

  const db = admin.firestore();
  const auth = admin.auth();

  const coachDoc = await db.collection("Users").doc(coachUid).get();
  if (coachDoc.data()?.role !== "coach") {
    throw new functions.https.HttpsError("permission-denied", "Only coaches can delete students.");
  }

  const studentRef = db.collection("Users").doc(studentId);
  const studentSnap = await studentRef.get();
  if (!studentSnap.exists) {
    throw new functions.https.HttpsError("not-found", "Student not found.");
  }

  const studentData = studentSnap.data();
  const studentCoachId = studentData?.coachId ?? "";
  if (studentCoachId !== coachUid) {
    throw new functions.https.HttpsError("permission-denied", "Student does not belong to this coach.");
  }

  const parentId = (studentData?.parentId ?? "") as string;

  if (parentId) {
    try {
      await auth.deleteUser(parentId);
    } catch (e) {
      // Parent auth may already be deleted; continue to delete Firestore doc
    }
    try {
      await db.collection("Users").doc(parentId).delete();
    } catch (e) {
      // Ignore if already deleted
    }
  }

  try {
    await auth.deleteUser(studentId);
  } catch (e) {
    // Student auth may already be deleted
  }
  await studentRef.delete();

  return { success: true };
});
