import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_submission_repository.dart';
import 'package:polen_academy/domain/homework/usecases/get_homeworks_by_student_and_date_range.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/usecases/get_my_students.dart';
import 'package:polen_academy/presentation/coach/homeworks/bloc/homeworks_state.dart';
import 'package:polen_academy/service_locator.dart';

class HomeworksCubit extends Cubit<HomeworksState> {
  HomeworksCubit({required this.coachId}) : super(HomeworksState());

  final String coachId;

  Future<void> loadStudents() async {
    if (coachId.isEmpty) return;
    emit(state.copyWith(loading: true, errorMessage: null));
    final result = await sl<GetMyStudentsUseCase>().call(params: coachId);
    result.fold(
      (error) => emit(state.copyWith(loading: false, errorMessage: error)),
      (students) => emit(state.copyWith(loading: false, students: students)),
    );
  }

  void selectStudent(StudentEntity? student) {
    emit(
      state.copyWith(
        clearStudent: student == null,
        selectedStudent: student,
        clearHomeworks: true,
      ),
    );
    if (student != null) {
      _loadHomeworks(student.uid);
    }
  }

  void previousWeek() {
    final start = state.weekStart.subtract(const Duration(days: 7));
    final end = state.weekEnd.subtract(const Duration(days: 7));
    emit(state.copyWith(weekStart: start, weekEnd: end));
    if (state.selectedStudent != null) {
      _loadHomeworks(state.selectedStudent!.uid);
    }
  }

  void nextWeek() {
    final start = state.weekStart.add(const Duration(days: 7));
    final end = state.weekEnd.add(const Duration(days: 7));
    emit(state.copyWith(weekStart: start, weekEnd: end));
    if (state.selectedStudent != null) {
      _loadHomeworks(state.selectedStudent!.uid);
    }
  }

  Future<void> _loadHomeworks(String studentId) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    final result = await sl<GetHomeworksByStudentAndDateRangeUseCase>().call(
      params: GetHomeworksByStudentAndDateRangeParams(
        studentId: studentId,
        start: state.weekStart,
        end: state.weekEnd,
      ),
    );
    final list = result.fold((error) {
      emit(state.copyWith(loading: false, errorMessage: error));
      return <HomeworkEntity>[];
    }, (r) => r);
    if (list.isEmpty) {
      if (result.isRight()) {
        emit(
          state.copyWith(
            loading: false,
            homeworks: [],
            submissionByHomeworkId: {},
          ),
        );
      }
      return;
    }
    final homeworkIds = list.map((h) => h.id).toList();
    const allStatuses = [
      HomeworkSubmissionStatus.pending,
      HomeworkSubmissionStatus.completedByStudent,
      HomeworkSubmissionStatus.approved,
      HomeworkSubmissionStatus.missing,
      HomeworkSubmissionStatus.notDone,
    ];
    final subResult = await sl<HomeworkSubmissionRepository>()
        .getByHomeworkIdsAndStatus(homeworkIds, allStatuses);
    final submissionByHomeworkId = <String, HomeworkSubmissionEntity>{};
    subResult.fold((_) {}, (subs) {
      for (final sub in subs) {
        if (sub.studentId == studentId)
          submissionByHomeworkId[sub.homeworkId] = sub;
      }
    });
    emit(
      state.copyWith(
        loading: false,
        homeworks: list,
        submissionByHomeworkId: submissionByHomeworkId,
      ),
    );
  }

  Future<void> refresh() async {
    final student = state.selectedStudent;
    if (student != null) _loadHomeworks(student.uid);
  }

  void clearError() => emit(state.copyWith(errorMessage: null));
}
