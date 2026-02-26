import 'package:dartz/dartz.dart';
import 'package:polen_academy/domain/notification/entity/notification_entity.dart';

abstract class NotificationRepository {
  /// Tek bildirim oluşturur.
  Future<Either<String, void>> create(NotificationEntity notification);

  /// Birden fazla bildirim oluşturur (aynı anda veli + öğrenci vb.).
  Future<Either<String, void>> createMany(List<NotificationEntity> notifications);

  /// Kullanıcının bildirimlerini en yeni başta olacak şekilde getirir.
  Future<Either<String, List<NotificationEntity>>> getForUser(String userId, {int limit = 50});

  /// Kullanıcının okunmamış bildirim sayısı.
  Future<Either<String, int>> getUnreadCount(String userId);

  /// Bildirimi okundu işaretle.
  Future<Either<String, void>> markAsRead(String notificationId);

  /// Kullanıcının tüm bildirimlerini okundu işaretle.
  Future<Either<String, void>> markAllAsRead(String userId);

  /// Okunmamış sayısını dinle (realtime badge için).
  Stream<int> watchUnreadCount(String userId);
}
