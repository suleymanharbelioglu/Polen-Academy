import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/curriculum/usecases/get_curriculum_tree.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
import 'package:polen_academy/domain/goals/entity/topic_status.dart';
import 'package:polen_academy/domain/goals/usecases/get_student_topic_progress.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/usecases/get_student_by_uid.dart';
import 'package:polen_academy/presentation/coach/goals/bloc/goals_state.dart';
import 'package:polen_academy/service_locator.dart';

/// Öğrenci hedefler: sadece görüntüleme, değişiklik yok. Kendi verisi (öğrenci seçimi yok).
class StudentGoalsCubit extends Cubit<GoalsState> {
  StudentGoalsCubit({required this.studentId}) : super(const GoalsState()) {
    load();
  }

  final String studentId;

  Future<void> load() async {
    if (studentId.isEmpty) {
      emit(state.copyWith(
        loading: false,
        errorMessage: 'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
      ));
      return;
    }
    emit(state.copyWith(loading: true, errorMessage: null));

    final studentResult = await sl<GetStudentByUidUseCase>().call(params: studentId);
    if (isClosed) return;

    studentResult.fold(
      (error) => emit(state.copyWith(loading: false, errorMessage: error)),
      (student) {
        if (student == null) {
          emit(state.copyWith(loading: false, errorMessage: 'Öğrenci bulunamadı.'));
          return;
        }
        emit(state.copyWith(
          loading: false,
          students: [student],
          selectedStudent: student,
        ));
        _loadCurriculumAndProgress(student);
      },
    );
  }

  Future<void> _loadCurriculumAndProgress(StudentEntity student) async {
    final classLevel = student.studentClass;
    if (classLevel.isEmpty) {
      if (!isClosed) emit(state.copyWith(
        loading: false,
        errorMessage: 'Sınıf bilgisi bulunamadı. Koçunuzun sizin için sınıf tanımlaması gerekir.',
      ));
      return;
    }
    if (!isClosed) emit(state.copyWith(loading: true, errorMessage: null));

    final results = await Future.wait([
      sl<GetCurriculumTreeUseCase>().call(params: classLevel),
      sl<GetStudentTopicProgressUseCase>().call(params: student.uid),
    ]);
    if (isClosed) return;

    final treeResult = results[0] as Either<String, CurriculumTree>;
    final progressResult = results[1] as Either<String, Map<String, StudentTopicProgressEntity>>;

    treeResult.fold(
      (error) => emit(state.copyWith(loading: false, errorMessage: error)),
      (tree) {
        final focusIds = student.focusCourseIds;
        final filteredTree = focusIds.isNotEmpty
            ? CurriculumTree(
                courses: tree.courses.where((c) => focusIds.contains(c.course.id)).toList(),
              )
            : tree;
        progressResult.fold(
          (error) => emit(state.copyWith(
            loading: false,
            curriculumTree: filteredTree,
            errorMessage: error,
          )),
          (progressMap) => emit(state.copyWith(
            loading: false,
            curriculumTree: filteredTree,
            progressMap: progressMap,
          )),
        );
      },
    );
  }

  void selectCourse(String? courseId) {
    emit(state.copyWith(
      selectedCourseId: courseId,
      clearSelectedCourseId: courseId == null,
    ));
  }

  Future<void> refresh() async {
    final student = state.selectedStudent;
    if (student != null) _loadCurriculumAndProgress(student);
  }

  TopicStatus getKonuStatus(String topicId) =>
      state.progressMap[topicId]?.konuStatus ?? TopicStatus.none;

  TopicStatus getRevisionStatus(String topicId) =>
      state.progressMap[topicId]?.revisionStatus ?? TopicStatus.none;

  TopicStatus getUnitKonuStatus(UnitWithTopics unitWithTopics) {
    final topicIds = unitWithTopics.topics.map((t) => t.id).toList();
    if (topicIds.isEmpty) return TopicStatus.none;
    final statuses = topicIds.map((id) => getKonuStatus(id)).toList();
    final allCompleted = statuses.every((s) => s == TopicStatus.completed);
    final anySet = statuses.any((s) => s != TopicStatus.none);
    if (allCompleted) return TopicStatus.completed;
    if (anySet) return TopicStatus.incomplete;
    return TopicStatus.none;
  }

  TopicStatus getUnitRevisionStatus(UnitWithTopics unitWithTopics) {
    final topicIds = unitWithTopics.topics.map((t) => t.id).toList();
    if (topicIds.isEmpty) return TopicStatus.none;
    final statuses = topicIds.map((id) => getRevisionStatus(id)).toList();
    final allCompleted = statuses.every((s) => s == TopicStatus.completed);
    final anySet = statuses.any((s) => s != TopicStatus.none);
    if (allCompleted) return TopicStatus.completed;
    if (anySet) return TopicStatus.incomplete;
    return TopicStatus.none;
  }
}
