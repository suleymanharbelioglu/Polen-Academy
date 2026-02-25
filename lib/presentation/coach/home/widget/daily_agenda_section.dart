import 'package:flutter/material.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart'
    show SessionEntity, SessionStatus, sessionStatusColor;
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/my_agenda/widget/plan_session_dialog.dart';

class DailyAgendaSection extends StatelessWidget {
  const DailyAgendaSection({
    super.key,
    this.sessions = const [],
    this.coachId = '',
    this.students = const [],
    required this.onApprove,
    required this.onCancel,
    this.onSessionPlanned,
  });

  final List<SessionEntity> sessions;
  final String coachId;
  final List<StudentEntity> students;
  final Future<void> Function(String sessionId, [String? note]) onApprove;
  final Future<void> Function(String sessionId, [String? note]) onCancel;
  final VoidCallback? onSessionPlanned;

  @override
  Widget build(BuildContext context) {
    final todaySessions = List<SessionEntity>.from(sessions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Günün Ajandası',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.info_outline, size: 18, color: Colors.grey),
              const Spacer(),
              Material(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => _openPlanSession(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Seans Planla',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (todaySessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Bugün planlanmış seans yok.',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            )
          else
            ...todaySessions.map((s) {
              final sessionDay = DateTime(
                s.date.year,
                s.date.month,
                s.date.day,
              );
              final today = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              );
              final isSessionToday = sessionDay == today;
              final canApprove =
                  s.status == SessionStatus.scheduled && isSessionToday;
              return _SessionRow(
                session: s,
                canApprove: canApprove,
                onApprove: () => _showApproveDialog(context, s.id, onApprove),
                onCancel: () => _showCancelDialog(context, s.id, onCancel),
              );
            }),
        ],
      ),
    );
  }

  void _openPlanSession(BuildContext context) async {
    final created = await showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PlanSessionDialog(
        coachId: coachId,
        initialDate: DateTime.now(),
        students: students,
      ),
    );
    if (created != null) onSessionPlanned?.call();
  }
}

Future<void> _showApproveDialog(
  BuildContext context,
  String sessionId,
  Future<void> Function(String sessionId, [String? note]) onApprove,
) async {
  final result = await showDialog<({bool confirmed, String? note})>(
    context: context,
    builder: (ctx) {
      final controller = TextEditingController();
      return AlertDialog(
        backgroundColor: AppColors.secondBackground,
        title: const Text(
          'Seansı Onayla',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bu seansı gerçekleşti olarak işaretlemek istiyor musunuz? İsteğe bağlı not ekleyebilirsiniz.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                'Not (İsteğe bağlı)',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: controller,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  hintText: 'Örn: Konu, değerlendirme...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, (confirmed: false, note: null)),
            child: const Text('Kapat', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              final n = controller.text.trim();
              Navigator.pop(ctx, (confirmed: true, note: n.isEmpty ? null : n));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Onayla', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
  if (result != null && result.confirmed) {
    await LoadingOverlay.run(context, onApprove(sessionId, result.note));
  }
}

Future<void> _showCancelDialog(
  BuildContext context,
  String sessionId,
  Future<void> Function(String sessionId, [String? note]) onCancel,
) async {
  final result = await showDialog<({bool confirmed, String? note})>(
    context: context,
    builder: (ctx) {
      final controller = TextEditingController();
      return AlertDialog(
        backgroundColor: AppColors.secondBackground,
        title: const Text(
          'Seans Gerçekleşmedi',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bu seansı 'Gerçekleşmedi' olarak işaretlemek istediğinizden emin misiniz? İsteğe bağlı olarak bir not ekleyebilirsiniz.",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                'Not (İsteğe bağlı)',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: controller,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  hintText: 'Örn: Öğrenci katılmadı, teknik sorun...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, (confirmed: false, note: null)),
            child: const Text('Kapat', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              final n = controller.text.trim();
              Navigator.pop(ctx, (confirmed: true, note: n.isEmpty ? null : n));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Onayla', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
  if (result != null && result.confirmed) {
    await LoadingOverlay.run(context, onCancel(sessionId, result.note));
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.session,
    required this.canApprove,
    required this.onApprove,
    required this.onCancel,
  });

  final SessionEntity session;
  final bool canApprove;
  final VoidCallback onApprove;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final dotColor = sessionStatusColor(session);
    final isCompleted = session.status == SessionStatus.completed;
    final isCancelled = session.status == SessionStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.studentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${session.startTime}${session.endTime != null && session.endTime!.isNotEmpty ? ' - ${session.endTime}' : ''}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 28,
              ),
            )
          else if (!isCancelled) ...[
            IconButton(
              icon: Icon(
                Icons.check_circle_outline,
                color: canApprove ? Colors.green : Colors.grey,
                size: 28,
              ),
              onPressed: canApprove ? onApprove : null,
            ),
            IconButton(
              icon: const Icon(
                Icons.cancel_outlined,
                color: Colors.red,
                size: 28,
              ),
              onPressed: onCancel,
            ),
          ],
        ],
      ),
    );
  }
}
