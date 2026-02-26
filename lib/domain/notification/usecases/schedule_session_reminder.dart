import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/data/notification/source/notification_firebase_service.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/service_locator.dart';

/// Seans 1 gün önce akşam 20:00'de veli ve öğrenciye hatırlatma gönderilmek üzere kayıt oluşturur.
/// Cloud Function (scheduled) bu kayıtları okuyup FCM ile bildirim atar.
class ScheduleSessionReminderUseCase implements UseCase<Either<String, void>, SessionEntity> {
  @override
  Future<Either<String, void>> call({SessionEntity? params}) async {
    if (params == null) return const Right(null);
    final session = params;
    final studentResult = await sl<UserRepository>().getStudentByUid(session.studentId);
    final student = studentResult.fold((_) => null, (s) => s);
    final parentId = student?.parentId;
    return sl<NotificationFirebaseService>().saveScheduledSessionReminder(
      sessionId: session.id,
      studentId: session.studentId,
      parentId: parentId?.isNotEmpty == true ? parentId : null,
      sessionDate: session.date,
      sessionStartTime: session.startTime,
      studentName: session.studentName,
    );
  }
}
