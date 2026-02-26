import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// FCM token'ı Firestore Users dokümanına yazar. Cloud Function bildirim oluşturulduğunda
/// bu token ile push gönderebilir.
class FcmService {
  static const String _usersCollection = 'Users';

  /// Giriş yapmış kullanıcı için FCM token alır ve Firestore'a yazar.
  /// Uygulama açıldığında veya giriş sonrası çağrılmalı.
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
