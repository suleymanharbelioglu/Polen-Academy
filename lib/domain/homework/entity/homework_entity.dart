enum HomeworkType { topicBased, routine, freeText }

enum RoutineInterval { daily, weekly }

class HomeworkEntity {
  final String id;
  final String coachId;
  final List<String> studentIds;
  final HomeworkType type;
  final DateTime? startDate;
  final DateTime endDate;
  /// Ödevin verildiği gün (takvimde bu günde de listelenir).
  final DateTime? assignedDate;
  final String? optionalTime;
  final String? courseId;
  final List<String> topicIds;
  final String description;
  /// Linkler (ödev detayında tıklanabilir listelenir).
  final List<String> links;
  final List<String> youtubeUrls;
  final List<String> fileUrls;
  final bool goalKonuStudied;
  final bool goalRevisionDone;
  final bool goalResourceSolve;
  final RoutineInterval? routineInterval;
  final DateTime createdAt;

  const HomeworkEntity({
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

  bool get isForStudent => studentIds.isNotEmpty;

  bool isOnDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final start = startDate != null
        ? DateTime(startDate!.year, startDate!.month, startDate!.day)
        : null;
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    if (start != null && d.isBefore(start)) return false;
    return !d.isAfter(end);
  }

  /// Ödev bu tarihte listelensin (verildiği gün veya start–end aralığı).
  bool isVisibleOnDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    if (assignedDate != null) {
      final a = DateTime(assignedDate!.year, assignedDate!.month, assignedDate!.day);
      if (a == d) return true;
    }
    return isOnDate(date);
  }
}
