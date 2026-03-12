import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/notification/entity/notification_entity.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/service_locator.dart';

/// Öğrenci ödevi tamamladığında koça bildirim.
class NotifyHomeworkCompletedByStudentParams {
  final String coachId;
  final String studentName;
  final String? courseName;
  final List<String> topicNames;
  final String? description;
  final String homeworkId;

  const NotifyHomeworkCompletedByStudentParams({
    required this.coachId,
    required this.studentName,
    this.courseName,
    this.topicNames = const [],
    this.description,
    required this.homeworkId,
  });
}

class NotifyHomeworkCompletedByStudentUseCase
    implements UseCase<Either<String, void>, NotifyHomeworkCompletedByStudentParams> {
  @override
  Future<Either<String, void>> call({NotifyHomeworkCompletedByStudentParams? params}) async {
    if (params == null) return const Right(null);
    final now = DateTime.now();
    final title = 'Ödev tamamlandı';
    final List<String> parts = ['${params.studentName} ödevini tamamladı.'];
    if (params.courseName != null && params.courseName!.isNotEmpty) {
      parts.add('Ders: ${params.courseName}');
    }
    if (params.topicNames.isNotEmpty) {
      parts.add('Konu: ${params.topicNames.join(', ')}');
    }
    if (params.description != null && params.description!.trim().isNotEmpty) {
      parts.add(params.description!.trim());
    }
    final body = parts.join('\n');

    final notification = NotificationEntity(
      id: '',
      type: NotificationType.homeworkCompletedByStudent,
      recipientUserId: params.coachId,
      title: title,
      body: body,
      relatedId: params.homeworkId,
      createdAt: now,
    );
    return sl<NotificationRepository>().create(notification);
  }
}
