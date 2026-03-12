import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const HOMEWORKS_COLLECTION = "Homeworks";
const SUBMISSIONS_COLLECTION = "HomeworkSubmissions";
const USERS_COLLECTION = "Users";
const NOTIFICATIONS_COLLECTION = "notifications";

/** Tamamlanmış sayılan durumlar: bunlarda veliye gecikmiş bildirimi göndermiyoruz. */
const COMPLETED_STATUSES = ["approved", "completedByStudent", "missing", "notDone"];

/**
 * Türkiye (Istanbul) saatine göre bugünün 00:00 anını döndürür.
 */
function getStartOfTodayTurkey(): Date {
  const now = new Date();
  const s = now.toLocaleDateString("en-CA", { timeZone: "Europe/Istanbul" });
  const [y, m, d] = s.split("-").map(Number);
  return new Date(Date.UTC(y, m - 1, d) - 3 * 60 * 60 * 1000);
}

/**
 * Her gün Türkiye saati 20:00'da çalışır.
 * Son tarihi geçmiş ve henüz tamamlanmamış her ödev için veliye ayrı bir bildirim oluşturur.
 * Bildirim Firestore "notifications" koleksiyonuna yazılır; sendNotificationOnCreate FCM'i tetikler.
 */
export const sendOverdueHomeworkNotifications = functions
  .region("us-central1")
  .runWith({ timeoutSeconds: 120 })
  .pubsub.schedule("0 20 * * *")
  .timeZone("Europe/Istanbul")
  .onRun(async () => {
    const db = admin.firestore();
    const turkeyStart = getStartOfTodayTurkey();
    const endBefore = admin.firestore.Timestamp.fromDate(turkeyStart);

    const homeworksSnap = await db
      .collection(HOMEWORKS_COLLECTION)
      .where("endDate", "<", endBefore)
      .get();

    if (homeworksSnap.empty) {
      functions.logger.info("sendOverdueHomeworkNotifications: no overdue homeworks");
      return null;
    }

    let created = 0;
    for (const hDoc of homeworksSnap.docs) {
      const h = hDoc.data();
      const homeworkId = hDoc.id;
      const studentId = (h.studentId as string) ?? "";
      if (!studentId) continue;

      const subId = `${homeworkId}_${studentId}`;
      const subDoc = await db.collection(SUBMISSIONS_COLLECTION).doc(subId).get();
      const status = (subDoc.data()?.status as string) ?? "pending";
      if (COMPLETED_STATUSES.includes(status)) continue;

      const studentDoc = await db.collection(USERS_COLLECTION).doc(studentId).get();
      const studentData = studentDoc.data();
      const parentId = (studentData?.parentId as string) ?? "";
      if (!parentId) continue;

      const studentName =
        [studentData?.studentName, studentData?.studentSurname].filter(Boolean).join(" ") || "Öğrenci";
      const courseLabel =
        (h.courseName as string)?.trim() || (h.courseId as string)?.trim() || "Ödev";
      const topicNames = (h.topicNames as string[]) ?? [];
      const description = (h.description as string)?.trim() || "";

      const title = "Gecikmiş ödev";
      const parts = [`${studentName} - ${courseLabel} ödevi süresi geçti.`];
      if (topicNames.length > 0) {
        parts.push(`Konu: ${topicNames.join(", ")}`);
      }
      if (description) {
        parts.push(description);
      }
      const body = parts.join("\n");

      await db.collection(NOTIFICATIONS_COLLECTION).add({
        type: "homeworkOverdue",
        recipientUserId: parentId,
        title,
        body,
        relatedId: homeworkId,
        relatedId2: studentId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        readAt: null,
      });
      created++;
    }

    functions.logger.info("sendOverdueHomeworkNotifications: created", { count: created });
    return null;
  });
