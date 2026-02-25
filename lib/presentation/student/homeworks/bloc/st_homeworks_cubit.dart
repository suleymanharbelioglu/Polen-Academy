import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_submission_repository.dart';
import 'package:polen_academy/domain/homework/usecases/get_homeworks_by_student_and_date_range.dart';
import 'package:polen_academy/presentation/student/home/bloc/st_home_state.dart';
import 'package:polen_academy/presentation/student/homeworks/bloc/st_homeworks_state.dart';
import 'package:polen_academy/service_locator.dart';

class StHomeworksCubit extends Cubit<StHomeworksState> {
  StHomeworksCubit({required this.studentId}) : super(StHomeworksState()) {
    load();
  }

  final String studentId;

  void previousWeek() {
    final start = state.weekStart.subtract(const Duration(days: 7));
    final end = state.weekEnd.subtract(const Duration(days: 7));
    emit(state.copyWith(weekStart: start, weekEnd: end));
    _loadHomeworks();
  }

  void nextWeek() {
    final start = state.weekStart.add(const Duration(days: 7));
    final end = state.weekEnd.add(const Duration(days: 7));
    emit(state.copyWith(weekStart: start, weekEnd: end));
    _loadHomeworks();
  }

  Future<void> load() async {
    _loadHomeworks();
  }

  Future<void> refresh() async {
    _loadHomeworks();
  }

  Future<void> _loadHomeworks() async {
    if (studentId.isEmpty) return;
    emit(state.copyWith(loading: true, errorMessage: null));

    final result = await sl<GetHomeworksByStudentAndDateRangeUseCase>().call(
      params: GetHomeworksByStudentAndDateRangeParams(
        studentId: studentId,
        start: state.weekStart,
        end: state.weekEnd,
      ),
    );

    if (isClosed) return;

    final list = result.fold((error) {
      emit(state.copyWith(loading: false, errorMessage: error));
      return <HomeworkEntity>[];
    }, (l) => l);
    if (list.isEmpty && result.isLeft()) return;
    if (list.isEmpty) {
      emit(state.copyWith(loading: false, homeworks: [], submissionByHomeworkId: {}, clearHomeworks: true));
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
        if (sub.studentId == studentId) submissionByHomeworkId[sub.homeworkId] = sub;
      }
    });
    if (isClosed) return;
    emit(state.copyWith(
      loading: false,
      homeworks: list,
      submissionByHomeworkId: submissionByHomeworkId,
    ));
  }
}
