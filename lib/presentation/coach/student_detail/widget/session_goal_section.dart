import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';

class SessionGoalSection extends StatelessWidget {
  const SessionGoalSection({
    super.key,
    required this.targetSessionCount,
    required this.completedCount,
    required this.studentName,
    this.canEdit = false,
    this.onEditTarget,
    this.accentColor,
    this.forCoach = true,
  });

  final int? targetSessionCount;
  final int completedCount;
  final String studentName;
  final bool canEdit;
  final Future<void> Function(int newTarget)? onEditTarget;
  final Color? accentColor;
  final bool forCoach;

  bool get _isGoalReached =>
      targetSessionCount != null && completedCount >= targetSessionCount!;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primaryCoach;

    if (targetSessionCount == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white.withOpacity(0.6)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Henüz seans hedefi belirlenmedi.',
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14),
              ),
            ),
            if (canEdit && onEditTarget != null)
              IconButton(
                tooltip: 'Hedefi belirle',
                onPressed: () => _openEditDialog(context),
                icon: Icon(Icons.edit_outlined, color: accent),
              ),
          ],
        ),
      );
    }

    final target = targetSessionCount!;
    final progress = target > 0 ? (completedCount / target).clamp(0.0, 1.0) : 0.0;
    final remaining = (target - completedCount).clamp(0, target);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isGoalReached
            ? const Color(0xFF1B3A2F)
            : AppColors.secondBackground,
        borderRadius: BorderRadius.circular(16),
        border: _isGoalReached
            ? Border.all(color: const Color(0xFF4CAF50).withOpacity(0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (_isGoalReached)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.emoji_events, color: Color(0xFFFFD54F), size: 24),
                ),
              Expanded(
                child: Text(
                  'Seans Hedefi',
                  style: TextStyle(
                    color: _isGoalReached ? const Color(0xFF81C784) : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (canEdit && onEditTarget != null)
                IconButton(
                  tooltip: 'Hedefi düzenle',
                  onPressed: () => _openEditDialog(context),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: _isGoalReached ? const Color(0xFF81C784) : accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isGoalReached) ...[
            Text(
              forCoach
                  ? 'Tebrikler! $studentName ile hedeflenen $target seanslık çalışmayı tamamladınız.'
                  : 'Tebrikler! Hedeflenen $target seanslık çalışmanı tamamladın.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$completedCount / $target seans tamamlandı',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            Text(
              '$completedCount / $target seans tamamlandı',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              remaining > 0 ? '$remaining seans kaldı' : 'Son seansa ulaşıldı',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
            ),
          ],
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                _isGoalReached ? const Color(0xFF66BB6A) : accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditDialog(BuildContext context) async {
    if (onEditTarget == null) return;
    final controller = TextEditingController(
      text: targetSessionCount?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();
    final newValue = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondBackground,
        title: const Text(
          'Hedef Seans Sayısı',
          style: TextStyle(color: Colors.white),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Hedef seans sayısı',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryCoach),
              ),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Hedef seans sayısı gerekli';
              final count = int.tryParse(text);
              if (count == null) return 'Geçerli bir sayı girin';
              if (count < 1) return 'En az 1 seans olmalı';
              if (count > 999) return 'En fazla 999 seans olabilir';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx, int.parse(controller.text.trim()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCoach,
            ),
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (newValue != null) {
      await onEditTarget!(newValue);
    }
  }
}

Future<void> showSessionGoalReachedDialog(
  BuildContext context, {
  required String studentName,
  required int targetSessionCount,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.secondBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: Color(0xFFFFD54F), size: 56),
          const SizedBox(height: 16),
          const Text(
            'Hedef Tamamlandı!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$studentName ile hedeflenen $targetSessionCount seanslık çalışmayı tamamladınız. Harika iş!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Tamam', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    ),
  );
}
