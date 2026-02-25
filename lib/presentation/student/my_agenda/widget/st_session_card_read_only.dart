import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart'
    show SessionEntity, sessionStatusColor;

/// Öğrenci için sadece görüntüleme: seans bilgisi, müdahale yok.
class StSessionCardReadOnly extends StatelessWidget {
  const StSessionCardReadOnly({
    super.key,
    required this.session,
  });

  final SessionEntity session;

  @override
  Widget build(BuildContext context) {
    final statusColor = sessionStatusColor(session);

    return Card(
      color: AppColors.secondBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Seans',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            session.endTime != null && session.endTime!.isNotEmpty
                                ? '${session.startTime}-${session.endTime}'
                                : session.startTime,
                            style: TextStyle(
                              color: AppColors.primaryStudent.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (session.noteText.isNotEmpty ||
                          session.noteChips.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          session.noteText.isNotEmpty
                              ? session.noteText
                              : session.noteChips.join(', '),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
