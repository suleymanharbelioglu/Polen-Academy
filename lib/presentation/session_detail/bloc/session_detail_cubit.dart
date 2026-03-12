import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/utils/student_detail_range_helper.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_date_range.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';
import 'package:polen_academy/presentation/session_detail/bloc/session_detail_state.dart';
import 'package:polen_academy/service_locator.dart';

class SessionDetailCubit extends Cubit<SessionDetailState> {
  SessionDetailCubit() : super(const SessionDetailState());

  Future<void> load(StudentEntity student) async {
    if (state.student?.uid != student.uid) {
      emit(state.copyWith(student: student, rangeFilter: state.rangeFilter));
    }
    emit(state.copyWith(loading: true, error: null));

    final now = DateTime.now();
    final start = StudentDetailRangeHelper.rangeStart(
      state.rangeFilter,
      student,
      now,
    );
    final startNorm = DateTime(start.year, start.month, start.day);
    final endNorm = StudentDetailRangeHelper.sessionQueryEnd(now);

    final result = await sl<GetSessionsByDateRangeUseCase>().call(
      params: GetSessionsByDateRangeParams(
        coachId: student.coachId,
        start: startNorm,
        end: endNorm,
      ),
    );

    if (isClosed) return;

    result.fold(
      (e) => emit(state.copyWith(loading: false, error: e, sessions: [])),
      (list) {
        final forStudent = list
            .where((s) => s.studentId == student.uid)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        emit(state.copyWith(loading: false, sessions: forStudent));
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
