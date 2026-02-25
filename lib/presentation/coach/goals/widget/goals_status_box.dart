import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/goals/entity/topic_status.dart';

/// Konu/Tkr. kutusu: renk duruma göre, tıklanınca 3 (ünite) veya 4 (konu) seçenek.
class GoalsStatusBox extends StatelessWidget {
  const GoalsStatusBox({
    super.key,
    required this.status,
    this.onSelect,
    this.isUnit = false,
  });

  final TopicStatus status;
  /// null ise sadece görüntüleme (öğrenci hedefler sayfası).
  final void Function(TopicStatus)? onSelect;
  final bool isUnit;

  static Color colorFor(TopicStatus s) {
    switch (s) {
      case TopicStatus.completed:
        return const Color(0xFF4CAF50);
      case TopicStatus.notDone:
        return const Color(0xFFE53935);
      case TopicStatus.incomplete:
        return const Color(0xFFFBC02D);
      case TopicStatus.none:
        return const Color(0xFF5C5C5C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorFor(status),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onSelect != null ? () => _showMenu(context) : null,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 28,
          height: 28,
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    if (isUnit) {
      _showUnitMenu(context);
    } else {
      _showTopicMenu(context);
    }
  }

  void _showUnitMenu(BuildContext context) {
    final onSelect = this.onSelect!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UnitOption(
              label: 'Tümünü Tamamla',
              color: const Color(0xFF4CAF50),
              onTap: () {
                Navigator.pop(ctx);
                onSelect(TopicStatus.completed);
              },
            ),
            const SizedBox(height: 10),
            _UnitOption(
              label: 'Tümünü Yapılmadı',
              color: const Color(0xFFE53935),
              onTap: () {
                Navigator.pop(ctx);
                onSelect(TopicStatus.notDone);
              },
            ),
            const SizedBox(height: 10),
            _UnitOption(
              label: 'Tümünü Sıfırla',
              color: const Color(0xFF5C5C5C),
              onTap: () {
                Navigator.pop(ctx);
                onSelect(TopicStatus.none);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTopicMenu(BuildContext context) {
    final onSelect = this.onSelect!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UnitOption(
              label: 'Tamamlandı',
              color: const Color(0xFF4CAF50),
              onTap: () {
                Navigator.pop(ctx);
                onSelect(TopicStatus.completed);
              },
            ),
            const SizedBox(height: 10),
            _UnitOption(
              label: 'Yapılmadı',
              color: const Color(0xFFE53935),
              onTap: () {
                Navigator.pop(ctx);
                onSelect(TopicStatus.notDone);
              },
            ),
            const SizedBox(height: 10),
            _UnitOption(
              label: 'Eksik',
              color: const Color(0xFFFBC02D),
              onTap: () {
                Navigator.pop(ctx);
                onSelect(TopicStatus.incomplete);
              },
            ),
            const SizedBox(height: 10),
            _UnitOption(
              label: 'Sıfırla',
              color: const Color(0xFF9E9E9E),
              onTap: () {
                Navigator.pop(ctx);
                onSelect(TopicStatus.none);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitOption extends StatelessWidget {
  const _UnitOption({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
