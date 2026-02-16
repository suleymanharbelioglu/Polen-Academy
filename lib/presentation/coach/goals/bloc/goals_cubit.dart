import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/curriculum/usecases/get_curriculum_tree.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
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
    emit(state.copyWith(loading: true, errorMessage: null));
    final result = await sl<GetMyStudentsUseCase>().call(params: coachId);
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
    emit(state.copyWith(selectedCourseId: courseId));
  }

  Future<void> _loadCurriculumAndProgress(StudentEntity student) async {
    final classLevel = student.studentClass;
    if (classLevel.isEmpty) {
      emit(state.copyWith(errorMessage: 'Öğrencinin sınıfı belirtilmemiş.'));
      return;
    }
    emit(state.copyWith(loading: true, errorMessage: null));
    final treeResult = await sl<GetCurriculumTreeUseCase>().call(params: classLevel);
    final progressResult = await sl<GetStudentTopicProgressUseCase>().call(params: student.uid);
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

  Future<void> updateTopicProgress(String topicId, {bool? konuStudied, bool? revisionDone}) async {
    final student = state.selectedStudent;
    if (student == null) return;
    final current = state.progressMap[topicId];
    final updated = StudentTopicProgressEntity(
      studentId: student.uid,
      topicId: topicId,
      konuStudied: konuStudied ?? current?.konuStudied ?? false,
      revisionDone: revisionDone ?? current?.revisionDone ?? false,
    );
    final result = await sl<UpdateTopicProgressUseCase>().call(params: updated);
    result.fold(
      (error) => emit(state.copyWith(errorMessage: error)),
      (_) {
        final newMap = Map<String, StudentTopicProgressEntity>.from(state.progressMap);
        newMap[topicId] = updated;
        emit(state.copyWith(progressMap: newMap, errorMessage: null));
      },
    );
  }

  bool isKonuStudied(String topicId) =>
      state.progressMap[topicId]?.konuStudied ?? false;

  bool isRevisionDone(String topicId) =>
      state.progressMap[topicId]?.revisionDone ?? false;
}
