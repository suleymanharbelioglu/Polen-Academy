import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart' show SessionEntity, sessionStatusColor;
import 'package:polen_academy/presentation/coach/my_agenda/bloc/my_agenda_state.dart';

const List<String> _weekDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
const List<String> _monthNames = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
];

class AgendaCalendar extends StatelessWidget {
  const AgendaCalendar({
    super.key,
    required this.selectedMonth,
    required this.sessionsForMonth,
    required this.selectedDate,
    required this.onMonthPrevious,
    required this.onMonthNext,
    required this.onDateTap,
  });

  final DateTime selectedMonth;
  final List<SessionEntity> sessionsForMonth;
  final DateTime? selectedDate;
  final VoidCallback onMonthPrevious;
  final VoidCallback onMonthNext;
  final void Function(DateTime date) onDateTap;

  @override
  Widget build(BuildContext context) {
    final state = MyAgendaState(
      selectedMonth: selectedMonth,
      sessionsForMonth: sessionsForMonth,
    );
    final first = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final last = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final firstWeekday = first.weekday;
    final daysInMonth = last.day;
    final leadingEmpty = firstWeekday - 1;
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: onMonthPrevious,
            ),
            Text(
              '${_monthNames[selectedMonth.month - 1]} ${selectedMonth.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: onMonthNext,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _weekDays
              .map((d) => SizedBox(
                    width: 40,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        Table(
          children: List.generate(rows, (row) {
            return TableRow(
              children: List.generate(7, (col) {
                final index = row * 7 + col;
                if (index < leadingEmpty) {
                  return const SizedBox(height: 44, child: Center());
                }
                final day = index - leadingEmpty + 1;
                if (day > daysInMonth) {
                  return const SizedBox(height: 44, child: Center());
                }
                final date = DateTime(selectedMonth.year, selectedMonth.month, day);
                final isSelected = selectedDate != null &&
                    selectedDate!.year == date.year &&
                    selectedDate!.month == date.month &&
                    selectedDate!.day == date.day;
                final daySessions = state.sessionsOn(date);
                final isToday = DateTime.now().year == date.year &&
                    DateTime.now().month == date.month &&
                    DateTime.now().day == date.day;

                return GestureDetector(
                  onTap: () => onDateTap(date),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryCoach
                                : (isToday
                                    ? AppColors.primaryCoach.withOpacity(0.3)
                                    : null),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isSelected || isToday
                                  ? Colors.white
                                  : Colors.white70,
                              fontSize: 14,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (daySessions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: _DayDots(
                              sessions: daySessions,
                              maxDots: 5,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ],
    );
  }
}

const int _dayDotsMaxVisible = 5;

class _DayDots extends StatelessWidget {
  const _DayDots({
    required this.sessions,
    this.maxDots = _dayDotsMaxVisible,
  });

  final List<SessionEntity> sessions;
  final int maxDots;

  @override
  Widget build(BuildContext context) {
    final visible = sessions.take(maxDots).toList();
    final extra = sessions.length - visible.length;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 3,
      runSpacing: 2,
      children: [
        ...visible.map((session) {
          final color = sessionStatusColor(session);
          return Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 2,
                  spreadRadius: 0,
                ),
              ],
            ),
          );
        }),
        if (extra > 0)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              '+$extra',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
