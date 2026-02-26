import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/notification/entity/notification_entity.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/service_locator.dart';

/// Koç seans planladığında öğrenci ve veliye bildirim oluşturur.
class NotifySessionPlannedUseCase implements UseCase<Either<String, void>, SessionEntity> {
  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Future<Either<String, void>> call({SessionEntity? params}) async {
    if (params == null) return const Right(null);
    final session = params;
    final now = DateTime.now();
    final title = 'Yeni seans planlandı';
    final body = '${session.studentName} için ${_formatDate(session.date)} ${session.startTime}';

    final studentResult = await sl<UserRepository>().getStudentByUid(session.studentId);
    final student = studentResult.fold((_) => null, (s) => s);
    final recipientIds = <String>[session.studentId];
    if (student?.parentId.isNotEmpty == true) {
      recipientIds.add(student!.parentId);
    }

    final notifications = recipientIds
        .map((uid) => NotificationEntity(
              id: '',
              type: NotificationType.sessionPlanned,
              recipientUserId: uid,
              title: title,
              body: body,
              relatedId: session.id,
              createdAt: now,
            ))
        .toList();
    if (notifications.isEmpty) return const Right(null);
    return sl<NotificationRepository>().createMany(notifications);
  }
}
