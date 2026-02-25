import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';

/// Ödev teslimi: öğrencinin ödeve eklediği görsel URL'leri ve yaptı bilgisi bu modelde.
class HomeworkSubmissionModel {
  final String id;
  final String homeworkId;
  final String studentId;
  final String status;
  /// Öğrencinin eklediği görsellerin URL listesi (Firestore: uploadedUrls).
  final List<String> uploadedUrls;
  final DateTime? completedAt;
  final DateTime updatedAt;

  HomeworkSubmissionModel({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.status,
    this.uploadedUrls = const [],
    this.completedAt,
    required this.updatedAt,
  });

  static DateTime _parse(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    final p = DateTime.tryParse(value.toString());
    return p ?? DateTime.now();
  }

  factory HomeworkSubmissionModel.fromMap(Map<String, dynamic> map) {
    return HomeworkSubmissionModel(
      id: map['id'] ?? '',
      homeworkId: map['homeworkId'] ?? '',
      studentId: map['studentId'] ?? '',
      status: map['status'] as String? ?? 'pending',
      uploadedUrls: map['uploadedUrls'] != null ? List<String>.from(map['uploadedUrls'] as List) : [],
      completedAt: map['completedAt'] != null ? _parse(map['completedAt']) : null,
      updatedAt: _parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'homeworkId': homeworkId,
      'studentId': studentId,
      'status': status,
      'uploadedUrls': uploadedUrls,
      'updatedAt': updatedAt.toIso8601String(),
    };
    if (completedAt != null) map['completedAt'] = completedAt!.toIso8601String();
    return map;
  }
}

HomeworkSubmissionStatus _statusFromString(String s) {
  switch (s) {
    case 'completed_by_student':
      return HomeworkSubmissionStatus.completedByStudent;
    case 'approved':
      return HomeworkSubmissionStatus.approved;
    case 'missing':
      return HomeworkSubmissionStatus.missing;
    case 'not_done':
      return HomeworkSubmissionStatus.notDone;
    default:
      return HomeworkSubmissionStatus.pending;
  }
}

String _statusToString(HomeworkSubmissionStatus s) {
  switch (s) {
    case HomeworkSubmissionStatus.completedByStudent:
      return 'completed_by_student';
    case HomeworkSubmissionStatus.approved:
      return 'approved';
    case HomeworkSubmissionStatus.missing:
      return 'missing';
    case HomeworkSubmissionStatus.notDone:
      return 'not_done';
    default:
      return 'pending';
  }
}

extension HomeworkSubmissionModelX on HomeworkSubmissionModel {
  HomeworkSubmissionEntity toEntity() => HomeworkSubmissionEntity(
        id: id,
        homeworkId: homeworkId,
        studentId: studentId,
        status: _statusFromString(status),
        uploadedUrls: uploadedUrls,
        completedAt: completedAt,
        updatedAt: updatedAt,
      );
}

extension HomeworkSubmissionEntityX on HomeworkSubmissionEntity {
  HomeworkSubmissionModel toModel() => HomeworkSubmissionModel(
        id: id,
        homeworkId: homeworkId,
        studentId: studentId,
        status: _statusToString(status),
        uploadedUrls: uploadedUrls,
        completedAt: completedAt,
        updatedAt: updatedAt,
      );
}
