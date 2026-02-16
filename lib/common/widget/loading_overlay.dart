import 'package:flutter/material.dart';

/// Full-screen loading overlay: blocks touch, slightly dark barrier, centered
/// [CircularProgressIndicator]. Use [LoadingOverlay.run] to wrap an async operation
/// so the overlay is shown until the future completes.
class LoadingOverlay {
  LoadingOverlay._();

  /// Shows a non-dismissible overlay with dark barrier and centered progress.
  /// Call [hide] when the operation finishes (e.g. in finally).
  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => const _LoadingOverlay(),
    );
  }

  /// Hides the overlay (pops the top route). Call after [show] when loading ends.
  static void hide(BuildContext context) {
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Runs [future] while showing the overlay. Overlay is automatically hidden
  /// when the future completes (success or error). Returns the result of [future].
  /// Use this when you have a single async operation.
  static Future<T> run<T>(BuildContext context, Future<T> future) async {
    final navigator = Navigator.of(context);
    show(context);
    try {
      return await future;
    } finally {
      navigator.pop();
    }
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}
