import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/presentation/coach/my_agenda/bloc/my_agenda_cubit.dart';
import 'package:polen_academy/presentation/coach/my_agenda/bloc/my_agenda_state.dart';
import 'package:polen_academy/presentation/coach/my_agenda/widget/agenda_calendar.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/presentation/coach/my_agenda/widget/agenda_day_sheet.dart';
import 'package:polen_academy/service_locator.dart';

const List<String> _monthNames = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
];

class MyAgendaPage extends StatelessWidget {
  const MyAgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final coachId = sl<AuthFirebaseService>().getCurrentUserUid() ?? '';
    return BlocProvider(
      create: (_) => MyAgendaCubit(coachId: coachId)..load(),
      child: const _MyAgendaView(),
    );
  }
}

class _MyAgendaView extends StatelessWidget {
  const _MyAgendaView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyAgendaCubit, MyAgendaState>(
      builder: (context, state) {
        if (state.loading && state.sessionsForMonth.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (state.errorMessage != null && state.sessionsForMonth.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.read<MyAgendaCubit>().load(),
                  child: const Text('Tekrar dene', style: TextStyle(color: AppColors.primaryCoach)),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<MyAgendaCubit>().refresh();
          },
          color: AppColors.primaryCoach,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AgendaCalendar(
                  selectedMonth: state.selectedMonth,
                  sessionsForMonth: state.sessionsForMonth,
                  selectedDate: null,
                  onMonthPrevious: () => context.read<MyAgendaCubit>().previousMonth(),
                  onMonthNext: () => context.read<MyAgendaCubit>().nextMonth(),
                  onDateTap: (date) => _showDaySheet(context, date),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Yaklaşan Seanslar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _UpcomingList(
                  sessions: state.upcomingSessions,
                  onTap: (date) => _showDaySheet(context, date),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDaySheet(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<MyAgendaCubit>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: AgendaDaySheet(date: date),
          ),
        ),
      ),
    );
  }
}

class _UpcomingList extends StatelessWidget {
  const _UpcomingList({
    required this.sessions,
    required this.onTap,
  });

  final List<SessionEntity> sessions;
  final void Function(DateTime date) onTap;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Yaklaşan seans yok.',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }
    final displayed = sessions.take(10).toList();
    return Column(
      children: displayed.map<Widget>((s) {
        final date = s.date;
        final isToday = date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day;
        return InkWell(
          onTap: () => onTap(date),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryParent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s.studentName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  isToday ? 'Bugün' : '${date.day} ${_monthNames[date.month - 1]}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  s.startTime,
                  style: TextStyle(
                    color: AppColors.primaryCoach.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
