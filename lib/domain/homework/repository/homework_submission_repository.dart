import 'package:dartz/dartz.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';

abstract class HomeworkSubmissionRepository {
  Future<Either<String, List<HomeworkSubmissionEntity>>> getByHomeworkIdsAndStatus(
    List<String> homeworkIds,
    List<HomeworkSubmissionStatus> statuses,
  );

  Future<Either<String, HomeworkSubmissionEntity?>> getByHomeworkAndStudent(
    String homeworkId,
    String studentId,
  );

  Future<Either<String, void>> set(HomeworkSubmissionEntity submission);
}
