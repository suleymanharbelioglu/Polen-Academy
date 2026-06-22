import 'dart:async';

import 'package:flutter/material.dart';
import 'package:polen_academy/core/debug/auth_debug.dart';

extension AuthDebugRoute on Widget {
  /// MaterialPageRoute settings.name olarak kullanılır.
  String get debugRouteName => runtimeType.toString();
}

/// AuthDebug ile entegre navigator.
class AppNavigator {
  static void pushReplacement(BuildContext context, Widget widget) {
    _logNav('pushReplacement', widget);
    Navigator.pushReplacement(
      context,
      _route(widget),
    );
  }

  static void push(BuildContext context, Widget widget) {
    _logNav('push', widget);
    Navigator.push(context, _route(widget));
  }

  static void pushAndRemove(BuildContext context, Widget widget) {
    _logNav('pushAndRemove', widget);
    Navigator.pushAndRemoveUntil(
      context,
      _route(widget),
      (Route<dynamic> route) => false,
    );
  }

  static MaterialPageRoute<dynamic> _route(Widget widget) {
    return MaterialPageRoute<dynamic>(
      settings: RouteSettings(name: widget.debugRouteName),
      builder: (context) => widget,
    );
  }

  static void _logNav(String action, Widget widget) {
    unawaited(
      AuthDebug.log(
        context: 'Navigasyon ($action) → ${widget.debugRouteName}',
      ),
    );
  }
}
