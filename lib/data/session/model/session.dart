import 'package:polen_academy/domain/session/entity/session_entity.dart';

class SessionModel {
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
  final String status;
  final String? statusNote;
  final DateTime createdAt;

  SessionModel({
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
    this.status = 'scheduled',
    this.statusNote,
    required this.createdAt,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    final date = map['date'];
    final createdAt = map['createdAt'];
    return SessionModel(
      id: map['id'] ?? '',
      coachId: map['coachId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      date: _parseDateTime(date),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] as String?,
      isWeeklyRecurring: map['isWeeklyRecurring'] as bool? ?? false,
      noteChips: map['noteChips'] != null
          ? List<String>.from(map['noteChips'] as List)
          : const [],
      noteText: map['noteText'] ?? '',
      status: map['status'] as String? ?? 'scheduled',
      statusNote: map['statusNote'] as String?,
      createdAt: _parseDateTime(createdAt),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value.toString());
    return parsed ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'coachId': coachId,
      'studentId': studentId,
      'studentName': studentName,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'isWeeklyRecurring': isWeeklyRecurring,
      'noteChips': noteChips,
      'noteText': noteText,
      'status': status,
      if (statusNote != null) 'statusNote': statusNote,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

extension SessionModelX on SessionModel {
  SessionEntity toEntity() {
    return SessionEntity(
      id: id,
      coachId: coachId,
      studentId: studentId,
      studentName: studentName,
      date: date,
      startTime: startTime,
      endTime: endTime,
      isWeeklyRecurring: isWeeklyRecurring,
      noteChips: noteChips,
      noteText: noteText,
      status: _statusFromString(status),
      statusNote: statusNote,
      createdAt: createdAt,
    );
  }
}

extension SessionEntityX on SessionEntity {
  SessionModel toModel() {
    return SessionModel(
      id: id,
      coachId: coachId,
      studentId: studentId,
      studentName: studentName,
      date: date,
      startTime: startTime,
      endTime: endTime,
      isWeeklyRecurring: isWeeklyRecurring,
      noteChips: noteChips,
      noteText: noteText,
      status: status.name,
      statusNote: statusNote,
      createdAt: createdAt,
    );
  }
}

SessionStatus _statusFromString(String s) {
  switch (s) {
    case 'completed':
      return SessionStatus.completed;
    case 'cancelled':
      return SessionStatus.cancelled;
    default:
      return SessionStatus.scheduled;
  }
}
