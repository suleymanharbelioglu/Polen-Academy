import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/curriculum/entity/topic_entity.dart';

class TopicProgressRow extends StatelessWidget {
  const TopicProgressRow({
    super.key,
    required this.topic,
    required this.konuStudied,
    required this.revisionDone,
    required this.onKonuChanged,
    required this.onRevisionChanged,
  });

  final TopicEntity topic;
  final bool konuStudied;
  final bool revisionDone;
  final void Function(bool) onKonuChanged;
  final void Function(bool) onRevisionChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              topic.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          _StatusChip(
            label: 'Konu',
            isDone: konuStudied,
            onTap: () => onKonuChanged(!konuStudied),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Tekrar',
            isDone: revisionDone,
            onTap: () => onRevisionChanged(!revisionDone),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.isDone,
    required this.onTap,
  });

  final String label;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDone
          ? AppColors.primaryCoach.withOpacity(0.3)
          : AppColors.secondBackground,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            isDone ? 'Tamamlandı' : 'Bekliyor',
            style: TextStyle(
              color: isDone ? AppColors.primaryCoach : Colors.white54,
              fontSize: 12,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
