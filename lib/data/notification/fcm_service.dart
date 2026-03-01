import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// FCM token kaydı ve uygulama öndeyken gelen bildirimi sistem bildirimi olarak gösterme.
class FcmService {
  static const String _usersCollection = 'Users';

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'polen_academy_notifications',
    'Bildirimler',
    description: 'Polen Academy uygulama bildirimleri',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Local notifications ve FCM dinleyicileri. main() içinde çağır.
  /// - Ön planda: onMessage ile gelen mesajlar yerel bildirim olarak gösterilir.
  /// - Arka planda/kapalı: Sunucu FCM'de "notification" (title, body) gönderirse sistem bildirimi otomatik gösterilir.
  static Future<void> init() async {
    await _initLocalNotifications();
    await saveTokenIfLoggedIn();
    _setupForegroundMessageListener();
  }

  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (_) {},
    );
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  /// Uygulama açıkken (foreground) gelen FCM mesajları da sistem bildirimi olarak gösterilir.
  static void _setupForegroundMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        final title = message.notification?.title ??
            message.data['title'] ??
            'Bildirim';
        final body = message.notification?.body ??
            message.data['body'] ??
            '';
        showForegroundNotification(title, body);
      } catch (_) {
        // Bildirim gösterilemezse sessizce geç
      }
    });
  }

  /// Uygulama öndeyken gelen FCM ile sistem bildirimi (banner) gösterir.
  static Future<void> showForegroundNotification(String title, String body) async {
    const android = AndroidNotificationDetails(
      'polen_academy_notifications',
      'Bildirimler',
      channelDescription: 'Polen Academy uygulama bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: android, iOS: ios);
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _localNotifications.show(id, title, body, details);
  }

  /// Giriş yapmış kullanıcı için FCM token alır ve Firestore'a yazar.
  static Future<void> saveTokenIfLoggedIn() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final token = await messaging.getToken();
      if (token == null || token.isEmpty) return;
      await FirebaseFirestore.instance.collection(_usersCollection).doc(uid).set(
            {'fcmToken': token, 'fcmTokenUpdatedAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );
    } catch (_) {
      // İzin reddedildi veya token alınamadı - sessizce geç
    }
  }
}
