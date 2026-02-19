import 'package:flutter/material.dart' show Color;

enum SessionStatus {
  scheduled,
  completed,
  cancelled,
}

class SessionEntity {
  final String id;
  final String coachId;
  final String studentId;
  final String studentName;
  final DateTime date;
  final String startTime;
  final String? endTime;
  final bool isWeeklyRecurring;
  final List<String> noteChips;
  final String noteText;
  final SessionStatus status;
  /// İsteğe bağlı: seans onaylandığında veya gerçekleşmedi işaretlendiğinde eklenen not.
  final String? statusNote;
  final DateTime createdAt;

  const SessionEntity({
    required this.id,
    required this.coachId,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.startTime,
    this.endTime,
    this.isWeeklyRecurring = false,
    this.noteChips = const [],
    this.noteText = '',
    this.status = SessionStatus.scheduled,
    this.statusNote,
    required this.createdAt,
  });

  SessionEntity copyWith({
    String? id,
    String? coachId,
    String? studentId,
    String? studentName,
    DateTime? date,
    String? startTime,
    String? endTime,
    bool? isWeeklyRecurring,
    List<String>? noteChips,
    String? noteText,
    SessionStatus? status,
    String? statusNote,
    DateTime? createdAt,
  }) {
    return SessionEntity(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isWeeklyRecurring: isWeeklyRecurring ?? this.isWeeklyRecurring,
      noteChips: noteChips ?? this.noteChips,
      noteText: noteText ?? this.noteText,
      status: status ?? this.status,
      statusNote: statusNote ?? this.statusNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Seans renkleri: planlandı (mavi), bugün (sarı), geçti (kırmızı), yapıldı (yeşil), yapılmadı (kırmızı).
Color sessionStatusColor(SessionEntity session) {
  switch (session.status) {
    case SessionStatus.completed:
      return const Color(0xFF4CAF50); // yeşil
    case SessionStatus.cancelled:
      return const Color(0xFFE53935); // kırmızı
    case SessionStatus.scheduled:
      final d = DateTime(session.date.year, session.date.month, session.date.day);
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final now = DateTime.now();
      final sessionTime = session.startTime.split(':');
      final sessionDateTime = DateTime(d.year, d.month, d.day,
          sessionTime.length >= 2 ? int.tryParse(sessionTime[0]) ?? 0 : 0,
          sessionTime.length >= 2 ? int.tryParse(sessionTime[1]) ?? 0 : 0);
      if (d.isBefore(today) || sessionDateTime.isBefore(now))
        return const Color(0xFFE53935); // geçti - kırmızı
      if (d.year == today.year && d.month == today.month && d.day == today.day)
        return const Color(0xFFFBC02D); // bugün - sarı
      return const Color(0xFF42A5F5); // ileri tarih - mavi
  }
}

/// Takvim günü için tek renk: öncelik completed (yeşil) > cancelled (kırmızı) > scheduled (tarihe göre).
Color? daySessionsColor(List<SessionEntity> sessions, DateTime dayDate) {
  if (sessions.isEmpty) return null;
  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final d = DateTime(dayDate.year, dayDate.month, dayDate.day);
  if (sessions.any((s) => s.status == SessionStatus.completed)) return const Color(0xFF4CAF50);
  if (sessions.any((s) => s.status == SessionStatus.cancelled)) return const Color(0xFFE53935);
  if (d.isBefore(today)) return const Color(0xFFE53935);
  if (d.year == today.year && d.month == today.month && d.day == today.day) return const Color(0xFFFBC02D);
  return const Color(0xFF42A5F5);
}
