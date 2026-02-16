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
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
