import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// iOS cihazda terminale log düşürmek için `developer.log` + `print` birlikte kullanılır.
class AppDebugLog {
  AppDebugLog._();

  static void line(String tag, String message) {
    if (!kDebugMode) return;
    final text = '[$tag] $message';
    developer.log(text, name: tag, level: 800);
    // ignore: avoid_print
    print(text);
  }

  static void block(String tag, String message) {
    if (!kDebugMode) return;
    developer.log(message, name: tag, level: 800);
    // ignore: avoid_print
    print(message);
  }
}
