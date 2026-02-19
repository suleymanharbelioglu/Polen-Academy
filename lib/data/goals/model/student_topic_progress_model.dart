import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
import 'package:polen_academy/domain/goals/entity/topic_status.dart';

class StudentTopicProgressModel {
  final String studentId;
  final String topicId;
  final String konuStatus;
  final String revisionStatus;

  StudentTopicProgressModel({
    required this.studentId,
    required this.topicId,
    this.konuStatus = 'none',
    this.revisionStatus = 'none',
  });

  factory StudentTopicProgressModel.fromMap(Map<String, dynamic> map) {
    // Yeni alanlar varsa kullan, yoksa eski boolean'lardan türet
    String konu = map['konuStatus'] as String? ?? '';
    if (konu.isEmpty && map['konuStudied'] == true) konu = 'completed';
    if (konu.isEmpty) konu = 'none';

    String rev = map['revisionStatus'] as String? ?? '';
    if (rev.isEmpty && map['revisionDone'] == true) rev = 'completed';
    if (rev.isEmpty) rev = 'none';

    return StudentTopicProgressModel(
      studentId: map['studentId'] ?? '',
      topicId: map['topicId'] ?? '',
      konuStatus: konu,
      revisionStatus: rev,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'topicId': topicId,
      'konuStatus': konuStatus,
      'revisionStatus': revisionStatus,
    };
  }

  static String docId(String studentId, String topicId) =>
      '${studentId}_$topicId';

  StudentTopicProgressEntity toEntity() => StudentTopicProgressEntity(
        studentId: studentId,
        topicId: topicId,
        konuStatus: TopicStatus.fromString(konuStatus),
        revisionStatus: TopicStatus.fromString(revisionStatus),
      );
}
