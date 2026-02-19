import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/usecases/get_my_students.dart';
import 'package:polen_academy/presentation/coach/my_agenda/bloc/my_agenda_cubit.dart';
import 'package:polen_academy/presentation/coach/my_agenda/bloc/my_agenda_state.dart';
import 'package:polen_academy/presentation/coach/my_agenda/widget/plan_session_dialog.dart';
import 'package:polen_academy/presentation/coach/my_agenda/widget/session_card.dart';
import 'package:polen_academy/service_locator.dart';

const List<String> _monthNames = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
];

class AgendaDaySheet extends StatelessWidget {
  const AgendaDaySheet({
    super.key,
    required this.date,
  });

  final DateTime date;

  static String _formatDate(DateTime d) {
    return '${d.day} ${_monthNames[d.month - 1]} ${d.year}';
  }

  /// Bugünden önceki günler için true (seans ekle butonu gösterilmez).
  static bool _isPastDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return d.isBefore(today);
  }

  /// Sadece bugünün tarihi için true (onay/iptal butonları gösterilir).
  static bool _isToday(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return d == today;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyAgendaCubit, MyAgendaState>(
      builder: (context, state) {
        final sessions = state.sessionsOn(date);
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              const Text(
                'Seanslar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              sessions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Seans yok.',
                          style: TextStyle(color: Colors.white54, fontSize: 15),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sessions.length,
                      itemBuilder: (context, i) => SessionCard(
                        session: sessions[i],
                        onRefresh: () => context.read<MyAgendaCubit>().refresh(),
                        canMarkStatus: _isToday(date),
                      ),
                    ),
              if (!_isPastDate(date)) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _openAddSession(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Seans Ekle',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAddSession(BuildContext context) async {
    final coachId = context.read<MyAgendaCubit>().coachId;
    final studentsResult = await sl<GetMyStudentsUseCase>().call(params: coachId);
    if (!context.mounted) return;
    final students = studentsResult.fold((_) => <StudentEntity>[], (list) => list);
    final created = await showDialog<SessionEntity>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PlanSessionDialog(
        coachId: coachId,
        initialDate: date,
        students: students,
      ),
    );
    if (created != null && context.mounted) {
      context.read<MyAgendaCubit>().refresh();
    }
  }
}
