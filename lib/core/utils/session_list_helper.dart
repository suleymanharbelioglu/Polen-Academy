import 'package:polen_academy/domain/session/entity/session_entity.dart';

/// Seans listesi filtreleme; UI'da logic yok.
class SessionListHelper {
  SessionListHelper._();

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static List<SessionEntity> completed(List<SessionEntity> list) =>
      list.where((s) => s.status == SessionStatus.completed).toList();

  static List<SessionEntity> notDone(List<SessionEntity> list) =>
      list.where((s) => s.status == SessionStatus.cancelled).toList();

  static List<SessionEntity> future(List<SessionEntity> list) {
    final today = _today;
    return list.where((s) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      return d.isAfter(today) && s.status == SessionStatus.scheduled;
    }).toList();
  }
}
