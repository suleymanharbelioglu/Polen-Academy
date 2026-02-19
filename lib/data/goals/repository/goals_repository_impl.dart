import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/goals/model/student_topic_progress_model.dart';
import 'package:polen_academy/data/goals/source/goals_firebase_service.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
import 'package:polen_academy/domain/goals/entity/topic_status.dart';
import 'package:polen_academy/domain/goals/repository/goals_repository.dart';

class GoalsRepositoryImpl extends GoalsRepository {
  GoalsRepositoryImpl(this._service);
  final GoalsFirebaseService _service;

  @override
  Future<Either<String, Map<String, StudentTopicProgressEntity>>> getProgressByStudent(
    String studentId,
  ) async {
    final result = await _service.getByStudent(studentId);
    return result.map((list) {
      final map = <String, StudentTopicProgressEntity>{};
      for (final m in list) {
        map[m.topicId] = m.toEntity();
      }
      return map;
    });
  }

  @override
  Future<Either<String, void>> updateProgress(
    StudentTopicProgressEntity progress,
  ) async {
    final model = StudentTopicProgressModel(
      studentId: progress.studentId,
      topicId: progress.topicId,
      konuStatus: progress.konuStatus.value,
      revisionStatus: progress.revisionStatus.value,
    );
    return _service.set(model);
  }

  @override
  Future<Either<String, void>> setTopicStudied(String studentId, String topicId) async {
    final result = await getProgressByStudent(studentId);
    return result.fold(
      (l) => Left(l),
      (map) {
        final existing = map[topicId];
        final updated = StudentTopicProgressEntity(
          studentId: studentId,
          topicId: topicId,
          konuStatus: TopicStatus.completed,
          revisionStatus: existing?.revisionStatus ?? TopicStatus.none,
        );
        return updateProgress(updated);
      },
    );
  }
}
