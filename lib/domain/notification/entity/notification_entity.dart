/// Bildirim türleri: hangi olay sonucu oluşturuldu.
enum NotificationType {
  /// Koç seans planladı -> öğrenci + veli
  sessionPlanned,
  /// Seans 1 gün önce akşam 8 hatırlatma -> öğrenci + veli (Cloud Function ile gönderilir)
  sessionReminder,
  /// Seans tamamlandı veya iptal edildi -> öğrenci + veli
  sessionCompletedOrCancelled,
  /// Koç ödev atadı -> öğrenci
  homeworkAssigned,
  /// Öğrenci ödevi tamamladı -> koç
  homeworkCompletedByStudent,
  /// Koç ödevi tamamlandı/eksik/yapılmadı işaretledi -> öğrenci
  homeworkStatusByCoach,
  /// Ödev gecikmiş -> veli
  homeworkOverdue,
}

class NotificationEntity {
  final String id;
  final NotificationType type;
  final String recipientUserId;
  final String title;
  final String body;
  /// İlgili kaynak id (sessionId veya homeworkId)
  final String? relatedId;
  /// İkinci id (örn. homeworkId için studentId)
  final String? relatedId2;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.recipientUserId,
    required this.title,
    required this.body,
    this.relatedId,
    this.relatedId2,
    required this.createdAt,
    this.readAt,
  });

  bool get isRead => readAt != null;
}
