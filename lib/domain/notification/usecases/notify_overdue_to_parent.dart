import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/notification/entity/notification_entity.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/service_locator.dart';

/// Öğrencinin ödevi gecikmiş olduğunda veliye bildirim.
class NotifyOverdueToParentParams {
  final String studentId;
  final String studentName;
  final String homeworkId;
  final String? courseName;

  const NotifyOverdueToParentParams({
    required this.studentId,
    required this.studentName,
    required this.homeworkId,
    this.courseName,
  });
}

class NotifyOverdueToParentUseCase implements UseCase<Either<String, void>, NotifyOverdueToParentParams> {
  @override
  Future<Either<String, void>> call({NotifyOverdueToParentParams? params}) async {
    if (params == null) return const Right(null);
    final studentResult = await sl<UserRepository>().getStudentByUid(params.studentId);
    final student = studentResult.fold((_) => null, (s) => s);
    final parentId = student?.parentId;
    if (parentId == null || parentId.isEmpty) return const Right(null);

    final now = DateTime.now();
    final title = 'Gecikmiş ödev';
    final courseLabel = params.courseName?.isNotEmpty == true ? params.courseName! : 'Ödev';
    final body = '${params.studentName} - $courseLabel ödevi süresi geçti.';

    final notification = NotificationEntity(
      id: '',
      type: NotificationType.homeworkOverdue,
      recipientUserId: parentId,
      title: title,
      body: body,
      relatedId: params.homeworkId,
      relatedId2: params.studentId,
      createdAt: now,
    );
    return sl<NotificationRepository>().create(notification);
  }
}
