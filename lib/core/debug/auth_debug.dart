import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polen_academy/core/debug/app_debug_log.dart';

/// Uygulama genelinde oturum durumunu debug konsolunda gösterir.
/// Sadece debug build'de çalışır (`kDebugMode`).
class AuthDebug {
  AuthDebug._();

  static const String _tag = '[AUTH]';
  static StreamSubscription<User?>? _subscription;

  /// main() içinde Firebase init sonrası bir kez çağrılır.
  static void init() {
    if (!kDebugMode) return;

    unawaited(log(context: 'Uygulama başlatıldı'));

    _subscription?.cancel();
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        unawaited(log(context: 'Auth state değişti → oturum kapalı'));
      } else {
        unawaited(
          log(context: 'Auth state değişti → oturum açık (${user.email ?? user.uid})'),
        );
      }
    });
  }

  /// Oturum özeti. [context] hangi noktada loglandığını belirtir.
  static Future<void> log({
    required String context,
    String? extra,
  }) async {
    if (!kDebugMode) return;

    final lines = <String>[
      '╔════════════════════════════════════════════',
      '║ $_tag $context',
      '╠════════════════════════════════════════════',
    ];

    try {
      final projectId = Firebase.app().options.projectId;
      lines.add('║ Firebase proje : $projectId');
    } catch (e) {
      lines.add('║ Firebase proje : HATA ($e)');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      lines.add('║ Durum          : ❌ GİRİŞ YAPILMAMIS');
    } else {
      lines.add('║ Durum          : ✅ GİRİŞ YAPILMIŞ');
      lines.add('║ UID            : ${user.uid}');
      lines.add('║ Email          : ${user.email ?? "(yok)"}');
      lines.add('║ Anonim         : ${user.isAnonymous ? "evet" : "hayır"}');
      lines.add('║ Email doğrulama: ${user.emailVerified ? "evet" : "hayır"}');
      lines.add(
        '║ Son giriş      : ${user.metadata.lastSignInTime ?? "(bilinmiyor)"}',
      );

      final profile = await _fetchFirestoreProfile(user.uid);
      if (profile != null) {
        lines.add('║ Firestore rol  : ${profile['role'] ?? "(yok)"}');
        final name = [
          profile['firstName'],
          profile['lastName'],
        ].where((s) => s != null && s.toString().isNotEmpty).join(' ');
        if (name.isNotEmpty) lines.add('║ Firestore ad   : $name');
      } else {
        lines.add('║ Firestore rol  : (okunamadı veya doküman yok)');
      }

      final tokenStatus = await _tokenStatus(user);
      lines.add('║ Auth token     : $tokenStatus');
    }

    if (extra != null && extra.isNotEmpty) {
      lines.add('║ Not            : $extra');
    }

    lines.add('╚════════════════════════════════════════════');
    AppDebugLog.block('AUTH', lines.join('\n'));
  }

  static Future<Map<String, String>?> _fetchFirestoreProfile(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      final role = (data['role'] as String? ?? '').toString();
      String firstName;
      String lastName;
      if (role == 'student') {
        firstName = (data['studentName'] as String? ?? '').toString();
        lastName = (data['studentSurname'] as String? ?? '').toString();
      } else if (role == 'parent') {
        firstName = (data['parentName'] as String? ?? '').toString();
        lastName = (data['parentSurname'] as String? ?? '').toString();
      } else {
        firstName = (data['firstName'] as String? ?? '').toString();
        lastName = (data['lastName'] as String? ?? '').toString();
      }
      return {
        'role': role,
        'firstName': firstName,
        'lastName': lastName,
      };
    } catch (_) {
      return null;
    }
  }

  static Future<String> _tokenStatus(User user) async {
    try {
      final token = await user.getIdToken(false);
      if (token == null || token.isEmpty) return '❌ alınamadı';
      return '✅ OK (${token.length} karakter)';
    } catch (e) {
      return '❌ hata: $e';
    }
  }
}

/// Her sayfa geçişinde oturum durumunu loglar.
class AuthDebugNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute('Sayfa açıldı', route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute('Sayfa kapandı', route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _logRoute('Sayfa değiştirildi', newRoute);
  }

  void _logRoute(String action, Route<dynamic> route) {
    if (!kDebugMode) return;
    final name = route.settings.name ?? _routeLabel(route);
    unawaited(AuthDebug.log(context: '$action → $name'));
  }

  String _routeLabel(Route<dynamic> route) {
    final widget = route.settings.arguments;
    if (widget != null) return widget.runtimeType.toString();
    return route.runtimeType.toString();
  }
}
