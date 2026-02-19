import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_submission_repository.dart';
import 'package:polen_academy/service_locator.dart';

class SetHomeworkSubmissionStatusParams {
  final String homeworkId;
  final String studentId;
  final HomeworkSubmissionStatus status;

  const SetHomeworkSubmissionStatusParams({
    required this.homeworkId,
    required this.studentId,
    required this.status,
  });
}

class SetHomeworkSubmissionStatusUseCase
    implements UseCase<Either<String, void>, SetHomeworkSubmissionStatusParams> {
  @override
  Future<Either<String, void>> call({SetHomeworkSubmissionStatusParams? params}) async {
    final p = params!;
    final repo = sl<HomeworkSubmissionRepository>();
    final existing = await repo.getByHomeworkAndStudent(p.homeworkId, p.studentId);
    final now = DateTime.now();
    final HomeworkSubmissionEntity entity = existing.fold(
      (_) => HomeworkSubmissionEntity(
        id: '${p.homeworkId}_${p.studentId}',
        homeworkId: p.homeworkId,
        studentId: p.studentId,
        status: p.status,
        uploadedUrls: [],
        completedAt: p.status == HomeworkSubmissionStatus.approved ? now : null,
        updatedAt: now,
      ),
      (e) => HomeworkSubmissionEntity(
        id: e?.id ?? '${p.homeworkId}_${p.studentId}',
        homeworkId: p.homeworkId,
        studentId: p.studentId,
        status: p.status,
        uploadedUrls: e?.uploadedUrls ?? [],
        completedAt: p.status == HomeworkSubmissionStatus.approved ? now : e?.completedAt,
        updatedAt: now,
      ),
    );
    return repo.set(entity);
  }
}
