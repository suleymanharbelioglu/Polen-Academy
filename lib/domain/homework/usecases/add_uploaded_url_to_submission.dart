import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_submission_repository.dart';
import 'package:polen_academy/service_locator.dart';

class AddUploadedUrlToSubmissionParams {
  final String homeworkId;
  final String studentId;
  final String uploadedUrl;

  const AddUploadedUrlToSubmissionParams({
    required this.homeworkId,
    required this.studentId,
    required this.uploadedUrl,
  });
}

/// Öğrenci ödev yüklemesine URL ekler; durum pending ise completedByStudent yapar.
class AddUploadedUrlToSubmissionUseCase
    implements UseCase<Either<String, void>, AddUploadedUrlToSubmissionParams> {
  @override
  Future<Either<String, void>> call({AddUploadedUrlToSubmissionParams? params}) async {
    final p = params!;
    final repo = sl<HomeworkSubmissionRepository>();
    final existing = await repo.getByHomeworkAndStudent(p.homeworkId, p.studentId);
    return existing.fold(
      (err) async => Left(err),
      (e) async {
        final now = DateTime.now();
        final urls = <String>[...(e?.uploadedUrls ?? []), p.uploadedUrl];
        final newStatus = (e?.status == HomeworkSubmissionStatus.pending || e == null)
            ? HomeworkSubmissionStatus.completedByStudent
            : (e.status);
        final entity = HomeworkSubmissionEntity(
          id: e?.id ?? '${p.homeworkId}_${p.studentId}',
          homeworkId: p.homeworkId,
          studentId: p.studentId,
          status: newStatus,
          uploadedUrls: urls,
          completedAt: newStatus == HomeworkSubmissionStatus.completedByStudent ? now : e?.completedAt,
          updatedAt: now,
        );
        return repo.set(entity);
      },
    );
  }
}
