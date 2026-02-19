import 'package:polen_academy/domain/homework/entity/homework_entity.dart';

class HomeworkModel {
  final String id;
  final String coachId;
  final List<String> studentIds;
  final String type;
  final DateTime? startDate;
  final DateTime endDate;
  final DateTime? assignedDate;
  final String? optionalTime;
  final String? courseId;
  final List<String> topicIds;
  final String description;
  final List<String> links;
  final List<String> youtubeUrls;
  final List<String> fileUrls;
  final bool goalKonuStudied;
  final bool goalRevisionDone;
  final bool goalResourceSolve;
  final String? routineInterval;
  final DateTime createdAt;

  HomeworkModel({
    required this.id,
    required this.coachId,
    required this.studentIds,
    required this.type,
    this.startDate,
    required this.endDate,
    this.assignedDate,
    this.optionalTime,
    this.courseId,
    this.topicIds = const [],
    this.description = '',
    this.links = const [],
    this.youtubeUrls = const [],
    this.fileUrls = const [],
    this.goalKonuStudied = false,
    this.goalRevisionDone = false,
    this.goalResourceSolve = false,
    this.routineInterval,
    required this.createdAt,
  });

  static DateTime _parse(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    final p = DateTime.tryParse(value.toString());
    return p ?? DateTime.now();
  }

  static List<String> _parseLinks(Map<String, dynamic> map) {
    if (map['links'] != null && map['links'] is List) {
      return List<String>.from(map['links'] as List);
    }
    final single = map['link'] as String?;
    if (single != null && single.trim().isNotEmpty) return [single];
    return [];
  }

  factory HomeworkModel.fromMap(Map<String, dynamic> map) {
    final start = map['startDate'];
    final end = map['endDate'];
    final createdAt = map['createdAt'];
    return HomeworkModel(
      id: map['id'] ?? '',
      coachId: map['coachId'] ?? '',
      studentIds: map['studentIds'] != null
          ? List<String>.from(map['studentIds'] as List)
          : (map['studentId'] != null ? [map['studentId'] as String] : []),
      type: map['type'] as String? ?? 'topic_based',
      startDate: start != null ? _parse(start) : null,
      endDate: _parse(end),
      assignedDate: map['assignedDate'] != null ? _parse(map['assignedDate']) : null,
      optionalTime: map['optionalTime'] as String?,
      courseId: map['courseId'] as String?,
      topicIds: map['topicIds'] != null
          ? List<String>.from(map['topicIds'] as List)
          : [],
      description: map['description'] as String? ?? '',
      links: _parseLinks(map),
      youtubeUrls: map['youtubeUrls'] != null
          ? List<String>.from(map['youtubeUrls'] as List)
          : [],
      fileUrls: map['fileUrls'] != null
          ? List<String>.from(map['fileUrls'] as List)
          : [],
      goalKonuStudied: map['goalKonuStudied'] as bool? ?? false,
      goalRevisionDone: map['goalRevisionDone'] as bool? ?? false,
      goalResourceSolve: map['goalResourceSolve'] as bool? ?? false,
      routineInterval: map['routineInterval'] as String?,
      createdAt: _parse(createdAt),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'coachId': coachId,
      'studentIds': studentIds,
      'type': type,
      'endDate': endDate.toIso8601String(),
      'description': description,
      if (links.isNotEmpty) 'links': links,
      'youtubeUrls': youtubeUrls,
      'fileUrls': fileUrls,
      'goalKonuStudied': goalKonuStudied,
      'goalRevisionDone': goalRevisionDone,
      'goalResourceSolve': goalResourceSolve,
      'createdAt': createdAt.toIso8601String(),
    };
    if (startDate != null) map['startDate'] = startDate!.toIso8601String();
    if (assignedDate != null) map['assignedDate'] = assignedDate!.toIso8601String();
    if (optionalTime != null && optionalTime!.isNotEmpty)
      map['optionalTime'] = optionalTime;
    if (courseId != null && courseId!.isNotEmpty) map['courseId'] = courseId;
    if (topicIds.isNotEmpty) map['topicIds'] = topicIds;
    if (routineInterval != null) map['routineInterval'] = routineInterval;
    return map;
  }
}

extension HomeworkModelX on HomeworkModel {
  HomeworkEntity toEntity() {
    return HomeworkEntity(
      id: id,
      coachId: coachId,
      studentIds: studentIds,
      type: _typeFromString(type),
      startDate: startDate,
      endDate: endDate,
      assignedDate: assignedDate,
      optionalTime: optionalTime,
      courseId: courseId,
      topicIds: topicIds,
      description: description,
      links: links,
      youtubeUrls: youtubeUrls,
      fileUrls: fileUrls,
      goalKonuStudied: goalKonuStudied,
      goalRevisionDone: goalRevisionDone,
      goalResourceSolve: goalResourceSolve,
      routineInterval: routineInterval != null
          ? _routineFromString(routineInterval!)
          : null,
      createdAt: createdAt,
    );
  }
}

String _typeToString(HomeworkType t) {
  switch (t) {
    case HomeworkType.routine:
      return 'routine';
    case HomeworkType.freeText:
      return 'free_text';
    default:
      return 'topic_based';
  }
}

String? _routineToString(RoutineInterval? r) {
  if (r == null) return null;
  return r == RoutineInterval.weekly ? 'weekly' : 'daily';
}

extension HomeworkEntityX on HomeworkEntity {
  HomeworkModel toModel() {
    return HomeworkModel(
      id: id,
      coachId: coachId,
      studentIds: studentIds,
      type: _typeToString(type),
      startDate: startDate,
      endDate: endDate,
      assignedDate: assignedDate,
      optionalTime: optionalTime,
      courseId: courseId,
      topicIds: topicIds,
      description: description,
      links: links,
      youtubeUrls: youtubeUrls,
      fileUrls: fileUrls,
      goalKonuStudied: goalKonuStudied,
      goalRevisionDone: goalRevisionDone,
      goalResourceSolve: goalResourceSolve,
      routineInterval: _routineToString(routineInterval),
      createdAt: createdAt,
    );
  }
}

HomeworkType _typeFromString(String s) {
  switch (s) {
    case 'routine':
      return HomeworkType.routine;
    case 'free_text':
      return HomeworkType.freeText;
    default:
      return HomeworkType.topicBased;
  }
}

RoutineInterval _routineFromString(String s) {
  return s == 'weekly' ? RoutineInterval.weekly : RoutineInterval.daily;
}
