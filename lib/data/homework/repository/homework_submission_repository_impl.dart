import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/homework/model/homework_submission_model.dart';
import 'package:polen_academy/data/homework/source/homework_submission_firebase_service.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_submission_repository.dart';

class HomeworkSubmissionRepositoryImpl extends HomeworkSubmissionRepository {
  HomeworkSubmissionRepositoryImpl(this._service);
  final HomeworkSubmissionFirebaseService _service;

  static List<String> _statusStrings(List<HomeworkSubmissionStatus> statuses) {
    return statuses.map((s) {
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
    }).toList();
  }

  @override
  Future<Either<String, List<HomeworkSubmissionEntity>>> getByHomeworkIdsAndStatus(
    List<String> homeworkIds,
    List<HomeworkSubmissionStatus> statuses,
  ) async {
    final result = await _service.getByHomeworkIdsAndStatus(homeworkIds, _statusStrings(statuses));
    return result.map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<String, HomeworkSubmissionEntity?>> getByHomeworkAndStudent(
    String homeworkId,
    String studentId,
  ) async {
    final result = await _service.getByHomeworkAndStudent(homeworkId, studentId);
    return result.map((m) => m?.toEntity());
  }

  @override
  Future<Either<String, void>> set(HomeworkSubmissionEntity submission) async {
    final model = submission.toModel();
    return _service.set(model);
  }
}
