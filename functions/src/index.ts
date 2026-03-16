import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const STUDENT_EMAIL_DOMAIN = "polenacademy.com";

function toEmailLocalPart(firstName: string, lastName: string): string {
  const combined = `${(firstName || "").trim()}${(lastName || "").trim()}`.toLowerCase();
  const map: Record<string, string> = {
    "ğ": "g", "ü": "u", "ş": "s", "ö": "o", "ç": "c", "ı": "i", "İ": "i",
  };
  let out = "";
  for (const c of combined) {
    out += map[c] ?? c;
  }
  out = out.replace(/[^a-z0-9]/g, "");
  return out || "student";
}

function generatePassword(length = 12): string {
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
export const createStudent = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Coach must be logged in.",
      );
    }

    const coachUid = context.auth.uid;

    // Flutter tarafında StudentModel.toMap ile gelen alanlar
    const rawStudentName = (data.studentName ?? "") as string;
    const rawStudentSurname = (data.studentSurname ?? "") as string;
    const rawStudentClass = (data.studentClass ?? "") as string;
    const rawCoachId = (data.coachId ?? "") as string;
    const rawParentId = (data.parentId ?? "") as string;
    const rawProgress = data.progress;
    const rawFocusCourseIds = data.focusCourseIds;
    const rawAcademicField = data.academicField as string | undefined;

    const studentName = rawStudentName.trim();
    const studentSurname = rawStudentSurname.trim();
    const studentClass = rawStudentClass.trim();

    if (!studentName || !studentSurname || !studentClass) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "studentName, studentSurname and studentClass are required.",
      );
    }

    const db = admin.firestore();
    const auth = admin.auth();

    const coachDoc = await db.collection("Users").doc(coachUid).get();
    const coachRole = coachDoc.data()?.role;
    if (coachRole !== "coach") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only coaches can create students.",
      );
    }

    // E-posta üretimi
    const baseLocal = toEmailLocalPart(studentName, studentSurname);
    let localPart = baseLocal;
    let suffix = 0;
    let email = `${localPart}@${STUDENT_EMAIL_DOMAIN}`;

    let usersSnap = await db
      .collection("Users")
      .where("email", "==", email)
      .limit(1)
      .get();
    while (!usersSnap.empty) {
      suffix++;
      localPart = `${baseLocal}${suffix}`;
      email = `${localPart}@${STUDENT_EMAIL_DOMAIN}`;
      usersSnap = await db
        .collection("Users")
        .where("email", "==", email)
        .limit(1)
        .get();
    }

    const password = generatePassword(12);

    const userRecord = await auth.createUser({
      email,
      password,
      emailVerified: false,
    });
    const uid = userRecord.uid;

    const finalCoachId = rawCoachId || coachUid;
    const finalParentId = rawParentId || "";

    const focusIds = Array.isArray(rawFocusCourseIds)
      ? (rawFocusCourseIds as unknown[])
        .map((id) => String(id))
        .filter(Boolean)
      : [];

    const userData: Record<string, unknown> = {
      uid,
      studentName,
      studentSurname,
      email,
      studentClass,
      coachId: finalCoachId,
      parentId: finalParentId,
      role: "student",
      progress: typeof rawProgress === "number" ? rawProgress : 0,
      hasParent: !!finalParentId,
      focusCourseIds: focusIds,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const academicField =
      typeof rawAcademicField === "string" ? rawAcademicField.trim() : "";
    if (academicField !== "") {
      userData.academicField = academicField;
    }

    await db.collection("Users").doc(uid).set(userData);

    return { email, password, uid };
  });

export { createParent } from "./createParent";
export { deleteStudent } from "./deleteStudent";
export { updateUserPassword } from "./updateUserPassword";
export { sendNotificationOnCreate } from "./sendNotificationOnCreate";
export { sendSessionReminders } from "./sendSessionReminders";
export { sendOverdueHomeworkNotifications } from "./sendOverdueHomeworkNotifications";
