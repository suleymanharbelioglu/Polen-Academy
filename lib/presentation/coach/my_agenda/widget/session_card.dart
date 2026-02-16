import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/presentation/coach/my_agenda/bloc/my_agenda_cubit.dart';
import 'package:polen_academy/domain/user/usecases/get_my_students.dart';
import 'package:polen_academy/presentation/coach/my_agenda/widget/plan_session_dialog.dart';
import 'package:polen_academy/service_locator.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/domain/session/usecases/delete_session.dart';
import 'package:polen_academy/domain/session/usecases/update_session_status.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onRefresh,
  });

  final SessionEntity session;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final statusColor = session.status == SessionStatus.completed
        ? Colors.green
        : session.status == SessionStatus.cancelled
        ? Colors.grey
        : AppColors.primaryParent;

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
                if (session.status == SessionStatus.scheduled) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 22,
                    ),
                    onPressed: () =>
                        _updateStatus(context, SessionStatus.completed),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.orange,
                      size: 22,
                    ),
                    onPressed: () =>
                        _updateStatus(context, SessionStatus.cancelled),
                  ),
                ],
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white70,
                    size: 22,
                  ),
                  onPressed: () => _openEdit(context),
                ),
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

  Future<void> _updateStatus(BuildContext context, SessionStatus status) async {
    final result = await LoadingOverlay.run(
      context,
      sl<UpdateSessionStatusUseCase>().call(
        params: UpdateSessionStatusParams(
          sessionId: session.id,
          status: status,
        ),
      ),
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

  Future<void> _openEdit(BuildContext context) async {
    final cubit = context.read<MyAgendaCubit>();
    final coachId = cubit.coachId;
    final studentsResult = await sl<GetMyStudentsUseCase>().call(
      params: coachId,
    );
    if (!context.mounted) return;
    final students = studentsResult.fold(
      (_) => <StudentEntity>[],
      (list) => list,
    );
    final updated = await showDialog<SessionEntity>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PlanSessionDialog(
        coachId: coachId,
        initialDate: session.date,
        initialSession: session,
        students: students,
      ),
    );
    if (updated != null && context.mounted) {
      onRefresh();
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
