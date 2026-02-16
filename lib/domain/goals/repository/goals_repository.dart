import 'package:dartz/dartz.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';

abstract class GoalsRepository {
  /// Returns progress for all topics for the given student.
  /// Map key: topicId, value: progress. Missing topicId means not started (default false/false).
  Future<Either<String, Map<String, StudentTopicProgressEntity>>> getProgressByStudent(
    String studentId,
  );

  Future<Either<String, void>> updateProgress(StudentTopicProgressEntity progress);

  /// For homework module: set konuStudied to true when homework is completed.
  Future<Either<String, void>> setTopicStudied(String studentId, String topicId);
}
