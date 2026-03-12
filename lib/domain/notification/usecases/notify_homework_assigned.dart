import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/notification/entity/notification_entity.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/service_locator.dart';

/// Koç ödev atadığında öğrenciye bildirim.
class NotifyHomeworkAssignedUseCase implements UseCase<Either<String, void>, HomeworkEntity> {
  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Future<Either<String, void>> call({HomeworkEntity? params}) async {
    if (params == null) return const Right(null);
    final h = params;
    final now = DateTime.now();
    final title = 'Yeni ödev atandı';
    final courseLabel = h.courseName?.isNotEmpty == true ? h.courseName! : (h.courseId?.isNotEmpty == true ? h.courseId! : 'Ödev');
    final List<String> parts = ['Ders: $courseLabel'];
    if (h.topicNames.isNotEmpty) {
      parts.add('Konu: ${h.topicNames.join(', ')}');
    }
    parts.add('Son tarih: ${_formatDate(h.endDate)}');
    if (h.description.trim().isNotEmpty) {
      parts.add(h.description.trim());
    }
    final body = parts.join('\n');

    final notification = NotificationEntity(
      id: '',
      type: NotificationType.homeworkAssigned,
      recipientUserId: h.studentId,
      title: title,
      body: body,
      relatedId: h.id,
      createdAt: now,
    );
    return sl<NotificationRepository>().create(notification);
  }
}
