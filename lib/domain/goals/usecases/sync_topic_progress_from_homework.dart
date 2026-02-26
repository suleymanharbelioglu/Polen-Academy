import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
import 'package:polen_academy/domain/goals/entity/topic_status.dart';
import 'package:polen_academy/domain/goals/repository/goals_repository.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_repository.dart';
import 'package:polen_academy/service_locator.dart';

/// Konulu ödev koç tarafından tamamlandı/tamamlanmadı/eksik işaretlendiğinde,
/// ödevdeki konular için hedef kutularını (konu çalışması / tekrar) günceller.
class SyncTopicProgressFromHomeworkParams {
  final String homeworkId;
  final String studentId;
  final HomeworkSubmissionStatus status;

  const SyncTopicProgressFromHomeworkParams({
    required this.homeworkId,
    required this.studentId,
    required this.status,
  });
}

class SyncTopicProgressFromHomeworkUseCase
    implements UseCase<Either<String, void>, SyncTopicProgressFromHomeworkParams> {
  static TopicStatus _statusToTopicStatus(HomeworkSubmissionStatus s) {
    switch (s) {
      case HomeworkSubmissionStatus.approved:
        return TopicStatus.completed;
      case HomeworkSubmissionStatus.notDone:
        return TopicStatus.notDone;
      case HomeworkSubmissionStatus.missing:
        return TopicStatus.incomplete;
      default:
        return TopicStatus.none;
    }
  }

  @override
  Future<Either<String, void>> call({
    SyncTopicProgressFromHomeworkParams? params,
  }) async {
    final p = params!;
    if (p.status != HomeworkSubmissionStatus.approved &&
        p.status != HomeworkSubmissionStatus.notDone &&
        p.status != HomeworkSubmissionStatus.missing) {
      return const Right(null);
    }

    final homeworkResult = await sl<HomeworkRepository>().getById(p.homeworkId);
    final homework = homeworkResult.fold((e) => null, (h) => h);
    if (homework == null || homework.topicIds.isEmpty) return const Right(null);

    final topicStatus = _statusToTopicStatus(p.status);
    final progressResult = await sl<GoalsRepository>().getProgressByStudent(p.studentId);
    if (progressResult.isLeft()) {
      return progressResult.fold((e) => Left(e), (_) => const Right(null));
    }
    final progressMap = progressResult.fold((_) => <String, StudentTopicProgressEntity>{}, (m) => m);

    final goalsRepo = sl<GoalsRepository>();
    for (final topicId in homework.topicIds) {
      final existing = progressMap[topicId];
      final newKonu = homework.goalKonuStudied ? topicStatus : (existing?.konuStatus ?? TopicStatus.none);
      final newRevision = homework.goalRevisionDone ? topicStatus : (existing?.revisionStatus ?? TopicStatus.none);
      final updated = StudentTopicProgressEntity(
        studentId: p.studentId,
        topicId: topicId,
        konuStatus: newKonu,
        revisionStatus: newRevision,
      );
      final updateResult = await goalsRepo.updateProgress(updated);
      if (updateResult.isLeft()) {
        return updateResult.fold((e) => Left(e), (_) => const Right(null));
      }
    }
    return const Right(null);
  }
}
