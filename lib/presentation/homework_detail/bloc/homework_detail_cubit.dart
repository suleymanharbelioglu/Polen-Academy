import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/utils/student_detail_range_helper.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_submission_repository.dart';
import 'package:polen_academy/domain/homework/usecases/get_homeworks_by_student_and_date_range.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';
import 'package:polen_academy/presentation/homework_detail/bloc/homework_detail_state.dart';
import 'package:polen_academy/service_locator.dart';

class HomeworkDetailCubit extends Cubit<HomeworkDetailState> {
  HomeworkDetailCubit() : super(const HomeworkDetailState());

  Future<void> load(StudentEntity student) async {
    emit(state.copyWith(student: student, loading: true, error: null));

    final now = DateTime.now();
    final start = StudentDetailRangeHelper.rangeStart(
      state.rangeFilter,
      student,
      now,
    );
    final startNorm = DateTime(start.year, start.month, start.day);
    final endNorm = StudentDetailRangeHelper.rangeEnd(state.rangeFilter, now);

    final result = await sl<GetHomeworksByStudentAndDateRangeUseCase>().call(
      params: GetHomeworksByStudentAndDateRangeParams(
        studentId: student.uid,
        start: startNorm,
        end: endNorm,
      ),
    );

    if (isClosed) return;

    result.fold(
      (e) => emit(state.copyWith(
        loading: false,
        error: e,
        homeworks: [],
        submissionByHomeworkId: {},
      )),
      (list) async {
        if (list.isEmpty) {
          emit(state.copyWith(
            loading: false,
            homeworks: [],
            submissionByHomeworkId: {},
          ));
          return;
        }
        final ids = list.map((h) => h.id).toList();
        const statuses = [
          HomeworkSubmissionStatus.pending,
          HomeworkSubmissionStatus.completedByStudent,
          HomeworkSubmissionStatus.approved,
          HomeworkSubmissionStatus.missing,
          HomeworkSubmissionStatus.notDone,
        ];
        final subResult = await sl<HomeworkSubmissionRepository>()
            .getByHomeworkIdsAndStatus(ids, statuses);
        final submissionByHomeworkId = <String, HomeworkSubmissionEntity>{};
        subResult.fold((_) {}, (subs) {
          for (final sub in subs) {
            if (sub.studentId == student.uid) {
              submissionByHomeworkId[sub.homeworkId] = sub;
            }
          }
        });
        if (isClosed) return;
        final sorted = List<HomeworkEntity>.from(list)
          ..sort((a, b) {
            final da = a.assignedDate ?? a.createdAt;
            final db = b.assignedDate ?? b.createdAt;
            return db.compareTo(da);
          });
        emit(state.copyWith(
          loading: false,
          homeworks: sorted,
          submissionByHomeworkId: submissionByHomeworkId,
        ));
      },
    );
  }

  void setRangeFilter(StudentDetailRangeFilter filter) {
    if (state.rangeFilter == filter) return;
    emit(state.copyWith(rangeFilter: filter));
    final student = state.student;
    if (student != null) load(student);
  }
}
