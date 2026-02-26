import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/service_locator.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/domain/session/usecases/delete_session.dart';
import 'package:polen_academy/domain/session/usecases/update_session_status.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onRefresh,
    this.canMarkStatus = true,
  });

  final SessionEntity session;
  final VoidCallback onRefresh;
  /// Bugün veya geçmiş gün için true ise yapıldı/yapılmadı butonları gösterilir; gelecek günde gösterilmez.
  final bool canMarkStatus;

  @override
  Widget build(BuildContext context) {
    final statusColor = sessionStatusColor(session);

    return Card(
      color: AppColors.primaryCoach,
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
                              session.studentName,
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
                            session.startTime,
                            style: TextStyle(
                              color: AppColors.primaryCoach.withOpacity(0.9),
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (session.status == SessionStatus.scheduled && canMarkStatus) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 22,
                    ),
                    onPressed: () =>
                        _updateStatusWithNote(context, SessionStatus.completed),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 22,
                    ),
                    onPressed: () =>
                        _updateStatusWithNote(context, SessionStatus.cancelled),
                  ),
                ],
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 22,
                  ),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatusWithNote(BuildContext context, SessionStatus status) async {
    final isCompleted = status == SessionStatus.completed;
    final result = await showDialog<({bool confirmed, String? note})>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.secondBackground,
          title: Text(
            isCompleted ? 'Seansı Onayla' : 'Seans Gerçekleşmedi',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted
                      ? 'Bu seansı gerçekleşti olarak işaretlemek istiyor musunuz? İsteğe bağlı not ekleyebilirsiniz.'
                      : "Bu seansı 'Gerçekleşmedi' olarak işaretlemek istediğinizden emin misiniz? İsteğe bağlı not ekleyebilirsiniz.",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                const Text('Not (İsteğe bağlı)', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    hintText: isCompleted ? 'Örn: Konu, değerlendirme...' : 'Örn: Öğrenci katılmadı, teknik sorun...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? Colors.green : Colors.red,
              ),
              child: const Text('Onayla', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    if (result == null || !result.confirmed || !context.mounted) return;
    final updateResult = await LoadingOverlay.run(
      context,
      sl<UpdateSessionStatusUseCase>().call(
        params: UpdateSessionStatusParams(
          sessionId: session.id,
          status: status,
          statusNote: result.note,
        ),
      ),
    );
    if (context.mounted) {
      updateResult.fold(
        (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e), backgroundColor: Colors.red)),
        (_) => onRefresh(),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondBackground,
        title: const Text('Seansı Sil', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bu seansı silmek istediğinize emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final result = await LoadingOverlay.run(
      context,
      sl<DeleteSessionUseCase>().call(params: session.id),
    );
    if (context.mounted) {
      result.fold(
        (e) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e), backgroundColor: Colors.red)),
        (_) => onRefresh(),
      );
    }
  }
}
