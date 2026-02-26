import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/notification/model/notification_model.dart';
import 'package:polen_academy/data/notification/source/notification_firebase_service.dart';
import 'package:polen_academy/domain/notification/entity/notification_entity.dart';
import 'package:polen_academy/domain/notification/repository/notification_repository.dart';
import 'package:polen_academy/service_locator.dart';

class NotificationRepositoryImpl extends NotificationRepository {
  @override
  Future<Either<String, void>> create(NotificationEntity notification) async {
    final model = NotificationModel.fromEntity(notification);
    return sl<NotificationFirebaseService>().create(model);
  }

  @override
  Future<Either<String, void>> createMany(List<NotificationEntity> notifications) async {
    if (notifications.isEmpty) return const Right(null);
    final models = notifications.map(NotificationModel.fromEntity).toList();
    return sl<NotificationFirebaseService>().createMany(models);
  }

  @override
  Future<Either<String, List<NotificationEntity>>> getForUser(String userId, {int limit = 50}) async {
    final result = await sl<NotificationFirebaseService>().getForUser(userId, limit: limit);
    return result.fold(
      (l) => Left(l),
      (list) => Right(list.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<String, int>> getUnreadCount(String userId) async {
    return sl<NotificationFirebaseService>().getUnreadCount(userId);
  }

  @override
  Future<Either<String, void>> markAsRead(String notificationId) async {
    return sl<NotificationFirebaseService>().markAsRead(notificationId);
  }

  @override
  Future<Either<String, void>> markAllAsRead(String userId) async {
    return sl<NotificationFirebaseService>().markAllAsRead(userId);
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return sl<NotificationFirebaseService>().watchUnreadCount(userId);
  }
}
