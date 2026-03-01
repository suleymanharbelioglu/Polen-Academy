import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/notification/entity/notification_entity.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/service_locator.dart';

/// Seans tamamlandı veya iptal edildiğinde öğrenci ve veliye bildirim.
class NotifySessionStatusParams {
  final String sessionId;
  final String studentId;
  final String studentName;
  final DateTime date;
  final String startTime;
  final bool isCompleted;
  /// Seans konusu (noteChips + noteText)
  final String? sessionNote;
  /// Koç yorumu (tamamlandı/iptal edildi diye işaretlerken eklenen not)
  final String? statusNote;

  const NotifySessionStatusParams({
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.startTime,
    required this.isCompleted,
    this.sessionNote,
    this.statusNote,
  });
}

class NotifySessionStatusUseCase implements UseCase<Either<String, void>, NotifySessionStatusParams> {
  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Future<Either<String, void>> call({NotifySessionStatusParams? params}) async {
    if (params == null) return const Right(null);
    final now = DateTime.now();
    final title = params.isCompleted ? 'Seans tamamlandı' : 'Seans iptal edildi';
    String body = '${params.studentName} - ${_formatDate(params.date)} ${params.startTime}';
    if (params.statusNote != null && params.statusNote!.trim().isNotEmpty) {
      final note = params.statusNote!.trim();
      final trimmed = note.length > 100 ? '${note.substring(0, 97)}...' : note;
      body += '\nKoç yorumu: $trimmed';
    } else if (params.sessionNote != null && params.sessionNote!.trim().isNotEmpty) {
      final note = params.sessionNote!.trim();
      final trimmed = note.length > 100 ? '${note.substring(0, 97)}...' : note;
      body += '\nSeans konusu: $trimmed';
    }

    final studentResult = await sl<UserRepository>().getStudentByUid(params.studentId);
    final student = studentResult.fold((_) => null, (s) => s);
    final recipientIds = <String>[params.studentId];
    if (student?.parentId.isNotEmpty == true) {
      recipientIds.add(student!.parentId);
    }

    final notifications = recipientIds
        .map((uid) => NotificationEntity(
              id: '',
              type: NotificationType.sessionCompletedOrCancelled,
              recipientUserId: uid,
              title: title,
              body: body,
              relatedId: params.sessionId,
              createdAt: now,
            ))
        .toList();
    if (notifications.isEmpty) return const Right(null);
    return sl<NotificationRepository>().createMany(notifications);
  }
}
