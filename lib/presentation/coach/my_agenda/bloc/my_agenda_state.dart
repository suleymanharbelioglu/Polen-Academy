import 'package:polen_academy/domain/session/entity/session_entity.dart';

class MyAgendaState {
  final DateTime selectedMonth;
  final List<SessionEntity> sessionsForMonth;
  final bool loading;
  final String? errorMessage;

  const MyAgendaState({
    required this.selectedMonth,
    this.sessionsForMonth = const [],
    this.loading = false,
    this.errorMessage,
  });

  List<SessionEntity> get upcomingSessions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return sessionsForMonth
        .where((s) {
          final d = DateTime(s.date.year, s.date.month, s.date.day);
          return d.isAfter(today) || d.isAtSameMomentAs(today);
        })
        .toList()
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        if (c != 0) return c;
        return a.startTime.compareTo(b.startTime);
      });
  }

  List<SessionEntity> sessionsOn(DateTime date) {
    return sessionsForMonth.where((s) {
      return s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  bool hasSessionOn(DateTime date) {
    return sessionsForMonth.any((s) =>
        s.date.year == date.year &&
        s.date.month == date.month &&
        s.date.day == date.day);
  }
}
