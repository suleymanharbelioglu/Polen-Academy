import 'package:polen_academy/domain/goals/entity/topic_status.dart';

class StudentTopicProgressEntity {
  final String studentId;
  final String topicId;
  final TopicStatus konuStatus;
  final TopicStatus revisionStatus;

  StudentTopicProgressEntity({
    required this.studentId,
    required this.topicId,
    this.konuStatus = TopicStatus.none,
    this.revisionStatus = TopicStatus.none,
  });

  /// Eski homework modülü uyumluluğu: tamamlandı sayılır.
  bool get konuStudied => konuStatus == TopicStatus.completed;
  bool get revisionDone => revisionStatus == TopicStatus.completed;

  StudentTopicProgressEntity copyWith({
    String? studentId,
    String? topicId,
    TopicStatus? konuStatus,
    TopicStatus? revisionStatus,
  }) {
    return StudentTopicProgressEntity(
      studentId: studentId ?? this.studentId,
      topicId: topicId ?? this.topicId,
      konuStatus: konuStatus ?? this.konuStatus,
      revisionStatus: revisionStatus ?? this.revisionStatus,
    );
  }
}
