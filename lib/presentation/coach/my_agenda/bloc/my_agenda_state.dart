import 'package:polen_academy/domain/session/entity/session_entity.dart';

class MyAgendaState {
  final DateTime selectedMonth;
  final DateTime? selectedDate;
  final List<SessionEntity> sessionsForMonth;
  final bool loading;
  final String? errorMessage;

  const MyAgendaState({
    required this.selectedMonth,
    this.selectedDate,
    this.sessionsForMonth = const [],
    this.loading = false,
    this.errorMessage,
  });

  /// Yaklaşan seanslar: bugün dahil ileriye dönük en fazla 1 hafta.
  List<SessionEntity> get upcomingSessions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));
    return sessionsForMonth
        .where((s) {
          final d = DateTime(s.date.year, s.date.month, s.date.day);
          return !d.isBefore(today) && d.isBefore(weekEnd);
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

  /// Gün için seans sayısı (takvim noktaları için).
  int sessionCountOn(DateTime date) {
    return sessionsForMonth.where((s) =>
        s.date.year == date.year &&
        s.date.month == date.month &&
        s.date.day == date.day).length;
  }
}
