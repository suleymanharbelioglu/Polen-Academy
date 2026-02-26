import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart'
    show HomeworkSubmissionStatus;
import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/notification/entity/notification_entity.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/service_locator.dart';

/// Koç ödevi tamamlandı/eksik/yapılmadı işaretlediğinde öğrenciye bildirim.
class NotifyHomeworkStatusByCoachParams {
  final String studentId;
  final String homeworkId;
  final HomeworkSubmissionStatus status;
  final String? courseName;

  const NotifyHomeworkStatusByCoachParams({
    required this.studentId,
    required this.homeworkId,
    required this.status,
    this.courseName,
  });
}

class NotifyHomeworkStatusByCoachUseCase
    implements UseCase<Either<String, void>, NotifyHomeworkStatusByCoachParams> {
  static String _statusLabel(HomeworkSubmissionStatus s) {
    switch (s) {
      case HomeworkSubmissionStatus.approved:
        return 'Tamamlandı olarak onaylandı';
      case HomeworkSubmissionStatus.missing:
        return 'Eksik olarak işaretlendi';
      case HomeworkSubmissionStatus.notDone:
        return 'Yapılmadı olarak işaretlendi';
      case HomeworkSubmissionStatus.pending:
        return 'Beklemede';
      case HomeworkSubmissionStatus.completedByStudent:
        return 'Öğrenci tarafından tamamlandı';
    }
  }

  @override
  Future<Either<String, void>> call({NotifyHomeworkStatusByCoachParams? params}) async {
    if (params == null) return const Right(null);
    final now = DateTime.now();
    final title = 'Ödev durumu güncellendi';
    final body = _statusLabel(params.status);
    final suffix = params.courseName != null && params.courseName!.isNotEmpty
        ? ' (${params.courseName})'
        : '';
    final fullBody = '$body$suffix';

    final notification = NotificationEntity(
      id: '',
      type: NotificationType.homeworkStatusByCoach,
      recipientUserId: params.studentId,
      title: title,
      body: fullBody,
      relatedId: params.homeworkId,
      createdAt: now,
    );
    return sl<NotificationRepository>().create(notification);
  }
}
