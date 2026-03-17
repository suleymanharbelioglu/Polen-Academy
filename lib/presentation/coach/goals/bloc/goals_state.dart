import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

class GoalsState {
  final List<StudentEntity> students;
  final StudentEntity? selectedStudent;
  final CurriculumTree? curriculumTree;
  final String? selectedCourseId;
  final Map<String, StudentTopicProgressEntity> progressMap;
  final bool loading;
  final bool saving;
  final String? errorMessage;
  /// 11: "11. Sınıf" | "TYT"; 12/Mezun: "TYT" | "AYT" | "YDS". Müfredat bu seviyeye göre yüklenir.
  final String? selectedExamSection;

  const GoalsState({
    this.students = const [],
    this.selectedStudent,
    this.curriculumTree,
    this.selectedCourseId,
    this.progressMap = const {},
    this.loading = false,
    this.saving = false,
    this.errorMessage,
    this.selectedExamSection,
  });

  String? get classLevel => selectedStudent?.studentClass;

  /// Yüklenecek müfredat seviyesi: sekme seçiliyse o, değilse öğrencinin sınıfı.
  String? get effectiveCurriculumLevel =>
      selectedExamSection ?? selectedStudent?.studentClass;

  List<CourseWithUnits> get displayedCourses {
    final tree = curriculumTree;
    if (tree == null || tree.courses.isEmpty) return [];
    if (selectedCourseId == null) return tree.courses;
    return tree.courses.where((c) => c.course.id == selectedCourseId).toList();
  }

  GoalsState copyWith({
    List<StudentEntity>? students,
    StudentEntity? selectedStudent,
    CurriculumTree? curriculumTree,
    String? selectedCourseId,
    bool clearSelectedCourseId = false,
    Map<String, StudentTopicProgressEntity>? progressMap,
    bool? loading,
    bool? saving,
    String? errorMessage,
    bool clearSelectedStudent = false,
    bool clearCurriculum = false,
    bool clearProgress = false,
    String? selectedExamSection,
    bool clearSelectedExamSection = false,
  }) {
    return GoalsState(
      students: students ?? this.students,
      selectedStudent: clearSelectedStudent ? null : (selectedStudent ?? this.selectedStudent),
      curriculumTree: clearCurriculum ? null : (curriculumTree ?? this.curriculumTree),
      selectedCourseId: clearSelectedCourseId ? null : (selectedCourseId ?? this.selectedCourseId),
      progressMap: clearProgress ? {} : (progressMap ?? this.progressMap),
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      errorMessage: errorMessage,
      selectedExamSection: clearSelectedExamSection ? null : (selectedExamSection ?? this.selectedExamSection),
    );
  }
}
