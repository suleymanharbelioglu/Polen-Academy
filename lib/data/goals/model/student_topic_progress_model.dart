import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';

class StudentTopicProgressModel {
  final String studentId;
  final String topicId;
  final bool konuStudied;
  final bool revisionDone;

  StudentTopicProgressModel({
    required this.studentId,
    required this.topicId,
    this.konuStudied = false,
    this.revisionDone = false,
  });

  factory StudentTopicProgressModel.fromMap(Map<String, dynamic> map) {
    return StudentTopicProgressModel(
      studentId: map['studentId'] ?? '',
      topicId: map['topicId'] ?? '',
      konuStudied: map['konuStudied'] as bool? ?? false,
      revisionDone: map['revisionDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'topicId': topicId,
      'konuStudied': konuStudied,
      'revisionDone': revisionDone,
    };
  }

  static String docId(String studentId, String topicId) =>
      '${studentId}_$topicId';

  StudentTopicProgressEntity toEntity() => StudentTopicProgressEntity(
        studentId: studentId,
        topicId: topicId,
        konuStudied: konuStudied,
        revisionDone: revisionDone,
      );
}
