enum HomeworkSubmissionStatus {
  pending,
  completedByStudent,
  approved,
  missing,
  notDone,
}

class HomeworkSubmissionEntity {
  final String id;
  final String homeworkId;
  final String studentId;
  final HomeworkSubmissionStatus status;
  /// Öğrencinin eklediği görsellerin (yüklenen dosyaların) URL listesi.
  final List<String> uploadedUrls;
  final DateTime? completedAt;
  final DateTime updatedAt;

  const HomeworkSubmissionEntity({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.status,
    this.uploadedUrls = const [],
    this.completedAt,
    required this.updatedAt,
  });

  bool get isCompleted =>
      status == HomeworkSubmissionStatus.completedByStudent ||
      status == HomeworkSubmissionStatus.approved;

  /// Öğrenci ödevi yaptı olarak işaretlemiş (onay bekliyor veya onaylandı).
  bool get studentDidIt => isCompleted;
}
