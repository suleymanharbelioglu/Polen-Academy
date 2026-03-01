import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart'
    show SessionEntity, sessionStatusColor;

String _combinedSessionNote(SessionEntity session) {
  final parts = <String>[];
  if (session.noteChips.isNotEmpty) parts.add(session.noteChips.join(', '));
  if (session.noteText.isNotEmpty) parts.add(session.noteText);
  return parts.join('\n\n');
}

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
                          _combinedSessionNote(session),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (session.statusNote != null &&
                          session.statusNote!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Koç notu: ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  session.statusNote!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
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
