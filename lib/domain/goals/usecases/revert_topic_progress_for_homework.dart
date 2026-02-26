import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
import 'package:polen_academy/domain/goals/entity/topic_status.dart';
import 'package:polen_academy/domain/goals/repository/goals_repository.dart';
import 'package:polen_academy/domain/homework/repository/homework_repository.dart';
import 'package:polen_academy/service_locator.dart';

/// Ödev "Sıfırla" (pending) yapıldığında, o ödevin hedef konularına yansıyan
/// (konu çalışması / tekrar) ilerlemeyi sıfırlar.
class RevertTopicProgressForHomeworkParams {
  final String homeworkId;
  final String studentId;

  const RevertTopicProgressForHomeworkParams({
    required this.homeworkId,
    required this.studentId,
  });
}

class RevertTopicProgressForHomeworkUseCase
    implements UseCase<Either<String, void>, RevertTopicProgressForHomeworkParams> {
  @override
  Future<Either<String, void>> call({
    RevertTopicProgressForHomeworkParams? params,
  }) async {
    final p = params!;
    final homeworkResult = await sl<HomeworkRepository>().getById(p.homeworkId);
    final homework = homeworkResult.fold((e) => null, (h) => h);
    if (homework == null || homework.topicIds.isEmpty) return const Right(null);
    if (!homework.goalKonuStudied && !homework.goalRevisionDone) return const Right(null);

    final progressResult = await sl<GoalsRepository>().getProgressByStudent(p.studentId);
    if (progressResult.isLeft()) {
      return progressResult.fold((e) => Left(e), (_) => const Right(null));
    }
    final progressMap = progressResult.fold((_) => <String, StudentTopicProgressEntity>{}, (m) => m);
    final goalsRepo = sl<GoalsRepository>();

    for (final topicId in homework.topicIds) {
      final existing = progressMap[topicId];
      final newKonu = homework.goalKonuStudied
          ? TopicStatus.none
          : (existing?.konuStatus ?? TopicStatus.none);
      final newRevision = homework.goalRevisionDone
          ? TopicStatus.none
          : (existing?.revisionStatus ?? TopicStatus.none);
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
