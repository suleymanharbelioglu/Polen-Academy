import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/notification/model/notification_model.dart';

abstract class NotificationFirebaseService {
  Future<Either<String, void>> create(NotificationModel notification);
  Future<Either<String, void>> createMany(List<NotificationModel> notifications);
  Future<Either<String, List<NotificationModel>>> getForUser(String userId, {int limit = 50});
  Future<Either<String, int>> getUnreadCount(String userId);
  Future<Either<String, void>> markAsRead(String notificationId);
  Future<Either<String, void>> markAllAsRead(String userId);
  Stream<int> watchUnreadCount(String userId);
  Future<Either<String, void>> saveScheduledSessionReminder({
    required String sessionId,
    required String studentId,
    String? parentId,
    required DateTime sessionDate,
    required String sessionStartTime,
    required String studentName,
  });
}

class NotificationFirebaseServiceImpl extends NotificationFirebaseService {
  static const String _collection = 'notifications';

  @override
  Future<Either<String, void>> create(NotificationModel notification) async {
    try {
      final ref = FirebaseFirestore.instance.collection(_collection).doc();
      final map = notification.toMap();
      map['createdAt'] = Timestamp.fromDate(notification.createdAt);
      map['readAt'] = notification.readAt != null
          ? Timestamp.fromDate(notification.readAt!)
          : null;
      await ref.set(map);
      return const Right(null);
    } catch (e) {
      return Left('Bildirim oluşturulamadı: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> createMany(List<NotificationModel> notifications) async {
    if (notifications.isEmpty) return const Right(null);
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final n in notifications) {
        final ref = FirebaseFirestore.instance.collection(_collection).doc();
        final map = n.toMap();
        map['createdAt'] = Timestamp.fromDate(n.createdAt);
        map['readAt'] = n.readAt != null ? Timestamp.fromDate(n.readAt!) : null;
        batch.set(ref, map);
      }
      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left('Bildirimler oluşturulamadı: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<NotificationModel>>> getForUser(String userId, {int limit = 50}) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('recipientUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      final list = snapshot.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data['id'] = d.id;
        final createdAt = data['createdAt'];
        final readAt = data['readAt'];
        if (createdAt is Timestamp) data['createdAt'] = createdAt.toDate();
        if (readAt is Timestamp) data['readAt'] = readAt.toDate();
        return NotificationModel.fromMap(data);
      }).toList();
      return Right(list);
    } catch (e) {
      return Left('Bildirimler yüklenemedi: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, int>> getUnreadCount(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('recipientUserId', isEqualTo: userId)
          .where('readAt', isEqualTo: null)
          .count()
          .get();
      return Right(snapshot.count ?? 0);
    } catch (e) {
      return Left('Okunmamış sayısı alınamadı: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(notificationId)
          .update({'readAt': FieldValue.serverTimestamp()});
      return const Right(null);
    } catch (e) {
      return Left('Bildirim güncellenemedi: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> markAllAsRead(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('recipientUserId', isEqualTo: userId)
          .where('readAt', isEqualTo: null)
          .get();
      if (snapshot.docs.isEmpty) return const Right(null);
      final batch = FirebaseFirestore.instance.batch();
      for (final d in snapshot.docs) {
        batch.update(d.reference, {'readAt': FieldValue.serverTimestamp()});
      }
      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left('Bildirimler güncellenemedi: ${e.toString()}');
    }
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('recipientUserId', isEqualTo: userId)
        .where('readAt', isEqualTo: null)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Seans hatırlatması: 1 gün önce akşam 20:00'de gönderilmek üzere kaydedilir.
  /// Cloud Function (scheduled 20:00) bu koleksiyonu okuyup FCM ile bildirim gönderebilir.
  Future<Either<String, void>> saveScheduledSessionReminder({
    required String sessionId,
    required String studentId,
    String? parentId,
    required DateTime sessionDate,
    required String sessionStartTime,
    required String studentName,
  }) async {
    try {
      final dayBefore = DateTime(sessionDate.year, sessionDate.month, sessionDate.day)
          .subtract(const Duration(days: 1));
      final sendAt = DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 20, 0);
      if (sendAt.isBefore(DateTime.now())) return const Right(null); // geçmişe hatırlatma yok
      await FirebaseFirestore.instance.collection('scheduled_reminders').add({
        'type': 'session_reminder',
        'sessionId': sessionId,
        'studentId': studentId,
        'parentId': parentId,
        'studentName': studentName,
        'sessionDate': Timestamp.fromDate(sessionDate),
        'sessionStartTime': sessionStartTime,
        'sendAt': Timestamp.fromDate(sendAt),
      });
      return const Right(null);
    } catch (e) {
      return Left('Hatırlatma planlanamadı: ${e.toString()}');
    }
  }
}
