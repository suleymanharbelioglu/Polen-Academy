import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const FIRESTORE_BATCH_SIZE = 500;
const STORAGE_BUCKET = "polen-academy.firebasestorage.app";

/**
 * Firebase Storage download URL'den dosya path'ini çıkarır.
 * Format: https://firebasestorage.googleapis.com/v0/b/BUCKET/o/ENCODED_PATH?...
 */
function getStoragePathFromDownloadUrl(downloadUrl: string): string | null {
  try {
    const match = downloadUrl.match(/\/o\/(.+?)(\?|$)/);
    if (!match) return null;
    return decodeURIComponent(match[1]);
  } catch {
    return null;
  }
}

/** Storage bucket tipi (firebase-admin Bucket export etmediği için ReturnType kullanıyoruz). */
type StorageBucket = ReturnType<ReturnType<typeof admin.storage>["bucket"]>;

/**
 * Ödev dokümanındaki fileUrls listesindeki dosyaları Storage'dan siler.
 */
async function deleteHomeworkFilesFromStorage(
  bucket: StorageBucket,
  fileUrls: string[]
): Promise<void> {
  if (!fileUrls || !Array.isArray(fileUrls)) return;
  for (const url of fileUrls) {
    if (typeof url !== "string" || !url.trim()) continue;
    const path = getStoragePathFromDownloadUrl(url);
    if (!path) continue;
    try {
      await bucket.file(path).delete();
    } catch (e) {
      // Dosya zaten silinmiş veya yok; devam et
    }
  }
}

/**
 * Deletes a student and everything related:
 * - HomeworkSubmissions where studentId == studentId
 * - Homeworks where studentId == studentId (ödevler) + Storage'daki fileUrls dosyaları
 * - TopicProgress where studentId == studentId (hedef ilerlemesi)
 * - Parent: Auth + Users doc (when student has parent)
 * - Student: Auth + Users doc
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

  // 1) Öğrenciye ait ödev teslim kayıtları (HomeworkSubmissions)
  const submissionsSnap = await db.collection("HomeworkSubmissions")
    .where("studentId", "==", studentId)
    .get();
  if (!submissionsSnap.empty) {
    const batch = db.batch();
    submissionsSnap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }

  // 2) Öğrencinin idsi olan ödevler: Storage'daki kaynakları sil, sonra Firestore dokümanlarını sil
  const homeworksSnap = await db.collection("Homeworks")
    .where("studentId", "==", studentId)
    .get();
  const bucket = admin.storage().bucket(STORAGE_BUCKET);
  if (!homeworksSnap.empty) {
    for (const doc of homeworksSnap.docs) {
      const data = doc.data();
      const fileUrls = (data?.fileUrls ?? []) as string[];
      await deleteHomeworkFilesFromStorage(bucket, fileUrls);
    }
    for (let i = 0; i < homeworksSnap.docs.length; i += FIRESTORE_BATCH_SIZE) {
      const chunk = homeworksSnap.docs.slice(i, i + FIRESTORE_BATCH_SIZE);
      const batch = db.batch();
      chunk.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
    }
  }

  // 3) Öğrenci idsi içeren tüm seanslar (Sessions)
  const sessionsSnap = await db.collection("Sessions")
    .where("studentId", "==", studentId)
    .get();
  if (!sessionsSnap.empty) {
    const batch = db.batch();
    sessionsSnap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }

  // 4) Topic progress (hedef ilerlemesi)
  const topicProgressSnap = await db.collection("TopicProgress")
    .where("studentId", "==", studentId)
    .get();
  if (!topicProgressSnap.empty) {
    const batch = db.batch();
    topicProgressSnap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }

  // 5) Storage: öğrenci idsi ile isimlendirilmiş ödev dosyalarını sil (HomeworkFiles/{studentId}/)
  try {
    const [files] = await bucket.getFiles({ prefix: `HomeworkFiles/${studentId}/` });
    await Promise.all(files.map((file) => file.delete()));
  } catch (e) {
    // Prefix yoksa veya hata olursa devam et
  }

  // 6) Veli hesabı (varsa)
  const parentId = (studentData?.parentId ?? "") as string;
  if (parentId) {
    try {
      await auth.deleteUser(parentId);
    } catch (e) {
      // Parent auth may already be deleted
    }
    try {
      await db.collection("Users").doc(parentId).delete();
    } catch (e) {
      // Ignore if already deleted
    }
  }

  // 7) Öğrenci Auth + Users
  try {
    await auth.deleteUser(studentId);
  } catch (e) {
    // Student auth may already be deleted
  }
  await studentRef.delete();

  return { success: true };
});
