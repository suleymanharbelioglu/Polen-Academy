class StudentTopicProgressEntity {
  final String studentId;
  final String topicId;
  final bool konuStudied;
  final bool revisionDone;

  StudentTopicProgressEntity({
    required this.studentId,
    required this.topicId,
    this.konuStudied = false,
    this.revisionDone = false,
  });

  StudentTopicProgressEntity copyWith({
    String? studentId,
    String? topicId,
    bool? konuStudied,
    bool? revisionDone,
  }) {
    return StudentTopicProgressEntity(
      studentId: studentId ?? this.studentId,
      topicId: topicId ?? this.topicId,
      konuStudied: konuStudied ?? this.konuStudied,
      revisionDone: revisionDone ?? this.revisionDone,
    );
  }
}
