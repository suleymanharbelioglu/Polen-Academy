import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';

class AddHomeworkState {
  final HomeworkType type;
  final DateTime? startDate;
  final DateTime endDate;
  /// Ödevin verildiği gün (formun açıldığı gün, değiştirilmez).
  final DateTime? assignedDate;
  final String? optionalTime;
  final String? courseId;
  final List<String> topicIds;
  final String description;
  /// Linkler (Link ekle ile eklenir, başlık altında tıklanabilir listelenir).
  final List<String> links;
  final List<String> youtubeUrls;
  /// Yüklenen dosyaların Storage URL'leri (resim veya PDF).
  final List<String> fileUrls;
  final bool goalKonuStudied;
  final bool goalRevisionDone;
  final bool goalResourceSolve;
  final RoutineInterval? routineInterval;
  final CurriculumTree? curriculumTree;
  final bool loading;
  final String? errorMessage;

  const AddHomeworkState({
    this.type = HomeworkType.topicBased,
    this.startDate,
    required this.endDate,
    this.assignedDate,
    this.optionalTime = '23:59',
    this.courseId,
    this.topicIds = const [],
    this.description = '',
    this.links = const [],
    this.youtubeUrls = const [],
    this.fileUrls = const [],
    this.goalKonuStudied = true,
    this.goalRevisionDone = true,
    this.goalResourceSolve = true,
    this.routineInterval,
    this.curriculumTree,
    this.loading = false,
    this.errorMessage,
  });

  AddHomeworkState copyWith({
    HomeworkType? type,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? assignedDate,
    String? optionalTime,
    String? courseId,
    List<String>? topicIds,
    String? description,
    List<String>? links,
    List<String>? youtubeUrls,
    List<String>? fileUrls,
    bool? goalKonuStudied,
    bool? goalRevisionDone,
    bool? goalResourceSolve,
    RoutineInterval? routineInterval,
    CurriculumTree? curriculumTree,
    bool? loading,
    String? errorMessage,
  }) {
    return AddHomeworkState(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      assignedDate: assignedDate ?? this.assignedDate,
      optionalTime: optionalTime ?? this.optionalTime,
      courseId: courseId ?? this.courseId,
      topicIds: topicIds ?? this.topicIds,
      description: description ?? this.description,
      links: links ?? this.links,
      youtubeUrls: youtubeUrls ?? this.youtubeUrls,
      fileUrls: fileUrls ?? this.fileUrls,
      goalKonuStudied: goalKonuStudied ?? this.goalKonuStudied,
      goalRevisionDone: goalRevisionDone ?? this.goalRevisionDone,
      goalResourceSolve: goalResourceSolve ?? this.goalResourceSolve,
      routineInterval: routineInterval ?? this.routineInterval,
      curriculumTree: curriculumTree ?? this.curriculumTree,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}
