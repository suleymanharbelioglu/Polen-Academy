import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/presentation/coach/bottom_navbar/bloc/bottom_navbar_index_cubit.dart';
import 'package:polen_academy/presentation/coach/my_agenda/bloc/my_agenda_cubit.dart';
import 'package:polen_academy/presentation/coach/my_agenda/bloc/my_agenda_state.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart' show SessionEntity, sessionStatusColor;
import 'package:polen_academy/presentation/coach/my_agenda/widget/agenda_calendar.dart';
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

  static const int _agendaTabIndex = 3;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BottomNavbarIndexCubit, int>(
      listenWhen: (prev, curr) => curr == _agendaTabIndex && prev != _agendaTabIndex,
      listener: (context, _) => context.read<MyAgendaCubit>().refresh(),
      child: BlocBuilder<MyAgendaCubit, MyAgendaState>(
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AgendaCalendar(
                  selectedMonth: state.selectedMonth,
                  sessionsForMonth: state.sessionsForMonth,
                  selectedDate: state.selectedDate,
                  onMonthPrevious: () => context.read<MyAgendaCubit>().previousMonth(),
                  onMonthNext: () => context.read<MyAgendaCubit>().nextMonth(),
                  onDateTap: (date) {
                    context.read<MyAgendaCubit>().selectDate(date);
                    _showDaySheet(context, date);
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white24,
                        Colors.white24,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.2, 0.8, 1.0],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'Yaklaşan Seanslar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _UpcomingList(
                  sessions: state.upcomingSessions,
                  onTap: (date) => _showDaySheet(context, date),
                ),
              ],
            ),
          ),
        );
        },
      ),
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
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            'Yaklaşan seans yok.',
            style: TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ),
      );
    }
    return Column(
      children: sessions.map<Widget>((s) {
        final date = s.date;
        final isToday = date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day;
        final dotColor = sessionStatusColor(s);
        final timeText = s.endTime != null && s.endTime!.isNotEmpty
            ? '${s.startTime}-${s.endTime}'
            : s.startTime;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => onTap(date),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: dotColor.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.studentName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeText,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      isToday ? 'Bugün' : '${date.day} ${_monthNames[date.month - 1]} ${date.year}',
                      style: TextStyle(
                        color: isToday ? dotColor : Colors.white70,
                        fontSize: 13,
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
