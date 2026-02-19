import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/curriculum/usecases/get_curriculum_tree.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
import 'package:polen_academy/domain/goals/entity/topic_status.dart';
import 'package:polen_academy/domain/goals/usecases/get_student_topic_progress.dart';
import 'package:polen_academy/domain/goals/usecases/update_topic_progress.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/usecases/get_my_students.dart';
import 'package:polen_academy/presentation/coach/goals/bloc/goals_state.dart';
import 'package:polen_academy/service_locator.dart';

class GoalsCubit extends Cubit<GoalsState> {
  GoalsCubit({required this.coachId}) : super(const GoalsState());

  final String coachId;

  Future<void> loadStudents() async {
    if (coachId.isEmpty) return;
    if (!isClosed) emit(state.copyWith(loading: true, errorMessage: null));
    final result = await sl<GetMyStudentsUseCase>().call(params: coachId);
    if (isClosed) return;
    result.fold(
      (error) => emit(state.copyWith(loading: false, errorMessage: error)),
      (students) => emit(state.copyWith(
        loading: false,
        students: students,
        selectedStudent: state.selectedStudent,
        curriculumTree: state.curriculumTree,
        progressMap: state.progressMap,
      )),
    );
  }

  void selectStudent(StudentEntity? student) {
    emit(state.copyWith(
      selectedCourseId: null,
      clearCurriculum: true,
      clearProgress: true,
      clearSelectedStudent: student == null,
      selectedStudent: student,
    ));
    if (student != null) {
      _loadCurriculumAndProgress(student);
    }
  }

  void selectCourse(String? courseId) {
    emit(state.copyWith(
      selectedCourseId: courseId,
      clearSelectedCourseId: courseId == null,
    ));
  }

  Future<void> _loadCurriculumAndProgress(StudentEntity student) async {
    final classLevel = student.studentClass;
    if (classLevel.isEmpty) {
      if (!isClosed) emit(state.copyWith(errorMessage: 'Öğrencinin sınıfı belirtilmemiş.'));
      return;
    }
    if (!isClosed) emit(state.copyWith(loading: true, errorMessage: null));
    final treeResult = await sl<GetCurriculumTreeUseCase>().call(params: classLevel);
    final progressResult = await sl<GetStudentTopicProgressUseCase>().call(params: student.uid);
    if (isClosed) return;
    treeResult.fold(
      (error) => emit(state.copyWith(loading: false, errorMessage: error)),
      (tree) {
        progressResult.fold(
          (error) => emit(state.copyWith(
            loading: false,
            curriculumTree: tree,
            errorMessage: error,
          )),
          (progressMap) => emit(state.copyWith(
            loading: false,
            curriculumTree: tree,
            progressMap: progressMap,
          )),
        );
      },
    );
  }

  Future<void> refresh() async {
    final student = state.selectedStudent;
    if (student != null) _loadCurriculumAndProgress(student);
  }

  TopicStatus getKonuStatus(String topicId) =>
      state.progressMap[topicId]?.konuStatus ?? TopicStatus.none;

  TopicStatus getRevisionStatus(String topicId) =>
      state.progressMap[topicId]?.revisionStatus ?? TopicStatus.none;

  /// Ünite kutusu rengi: konulara göre türetilir. Hepsi tamamlandı → yeşil; hepsi değil ama en az biri işaretli → sarı (eksik); hiç işaret yok → gri.
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

  Future<void> updateTopicProgress(String topicId, {TopicStatus? konuStatus, TopicStatus? revisionStatus}) async {
    final student = state.selectedStudent;
    if (student == null) return;
    final current = state.progressMap[topicId];
    final updated = StudentTopicProgressEntity(
      studentId: student.uid,
      topicId: topicId,
      konuStatus: konuStatus ?? current?.konuStatus ?? TopicStatus.none,
      revisionStatus: revisionStatus ?? current?.revisionStatus ?? TopicStatus.none,
    );
    if (!isClosed) emit(state.copyWith(saving: true));
    final result = await sl<UpdateTopicProgressUseCase>().call(params: updated);
    if (isClosed) return;
    result.fold(
      (error) => emit(state.copyWith(saving: false, errorMessage: error)),
      (_) {
        final newMap = Map<String, StudentTopicProgressEntity>.from(state.progressMap);
        newMap[topicId] = updated;
        emit(state.copyWith(saving: false, progressMap: newMap, errorMessage: null));
      },
    );
  }

  /// Ünite kutusundan 3 seçenek: konuStatus verilirse tüm konuların Konu sütununu, revisionStatus verilirse Tkr. sütununu günceller.
  Future<void> updateUnitProgress(
    UnitWithTopics unitWithTopics, {
    TopicStatus? konuStatus,
    TopicStatus? revisionStatus,
  }) async {
    final student = state.selectedStudent;
    if (student == null) return;
    if (konuStatus == null && revisionStatus == null) return;
    final topicIds = unitWithTopics.topics.map((t) => t.id).toList();
    if (topicIds.isEmpty) return;
    if (!isClosed) emit(state.copyWith(saving: true));
    final newMap = Map<String, StudentTopicProgressEntity>.from(state.progressMap);
    for (final topicId in topicIds) {
      final current = newMap[topicId];
      final updated = StudentTopicProgressEntity(
        studentId: student.uid,
        topicId: topicId,
        konuStatus: konuStatus ?? current?.konuStatus ?? TopicStatus.none,
        revisionStatus: revisionStatus ?? current?.revisionStatus ?? TopicStatus.none,
      );
      final result = await sl<UpdateTopicProgressUseCase>().call(params: updated);
      result.fold(
        (_) => null,
        (_) => newMap[topicId] = updated,
      );
    }
    if (!isClosed) emit(state.copyWith(saving: false, progressMap: newMap, errorMessage: null));
  }

  bool isKonuStudied(String topicId) =>
      state.progressMap[topicId]?.konuStudied ?? false;

  bool isRevisionDone(String topicId) =>
      state.progressMap[topicId]?.revisionDone ?? false;
}
