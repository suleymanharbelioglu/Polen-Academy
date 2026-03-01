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
  final List<String> topicNames;
  final String? description;

  const NotifyOverdueToParentParams({
    required this.studentId,
    required this.studentName,
    required this.homeworkId,
    this.courseName,
    this.topicNames = const [],
    this.description,
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
    final List<String> parts = ['${params.studentName} - $courseLabel ödevi süresi geçti.'];
    if (params.topicNames.isNotEmpty) {
      parts.add('Konu: ${params.topicNames.join(', ')}');
    }
    if (params.description != null && params.description!.trim().isNotEmpty) {
      final d = params.description!.trim();
      parts.add(d.length > 80 ? '${d.substring(0, 77)}...' : d);
    }
    final body = parts.join('\n');

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
