import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/domain/homework/usecases/set_homework_submission_status.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_date.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/session/usecases/update_session_status.dart';
import 'package:polen_academy/domain/user/usecases/get_my_students.dart';
import 'package:polen_academy/presentation/coach/home/bloc/home_state.dart';
import 'package:polen_academy/service_locator.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.coachId}) : super(const HomeState()) {
    load();
  }

  final String coachId;

  Future<void> load() async {
    if (coachId.isEmpty) return;
    if (!isClosed) emit(state.copyWith(loading: true, errorMessage: null));
    final now = DateTime.now();
    final sessionResult = await sl<GetSessionsByDateUseCase>().call(
      params: GetSessionsByDateParams(coachId: coachId, date: now),
    );
    final studentsResult = await sl<GetMyStudentsUseCase>().call(params: coachId);
    final completedResult = await sl<GetCompletedHomeworksForCoachUseCase>().call(params: coachId);
    if (isClosed) return;

    final todaySessions = sessionResult.fold((_) => <SessionEntity>[], (list) => list);
    final students = studentsResult.fold((_) => state.students, (list) => list);
    final completed = completedResult.fold((_) => state.completedHomeworks, (list) => list);
    final errorMessage = sessionResult.fold(
      (e) => e,
      (_) => studentsResult.fold(
        (e) => e,
        (_) => completedResult.fold((e) => e, (_) => null),
      ),
    );
    emit(state.copyWith(
      loading: false,
      todaySessions: todaySessions,
      students: students,
      completedHomeworks: completed,
      errorMessage: errorMessage,
    ));
  }

  Future<void> approveSession(String sessionId, [String? statusNote]) async {
    final result = await sl<UpdateSessionStatusUseCase>().call(
      params: UpdateSessionStatusParams(sessionId: sessionId, status: SessionStatus.completed, statusNote: statusNote),
    );
    result.fold(
      (e) => emit(state.copyWith(errorMessage: e)),
      (_) => load(),
    );
  }

  Future<void> cancelSession(String sessionId, [String? statusNote]) async {
    final result = await sl<UpdateSessionStatusUseCase>().call(
      params: UpdateSessionStatusParams(sessionId: sessionId, status: SessionStatus.cancelled, statusNote: statusNote),
    );
    result.fold(
      (e) => emit(state.copyWith(errorMessage: e)),
      (_) => load(),
    );
  }

  Future<void> setSubmissionStatus(String homeworkId, String studentId, HomeworkSubmissionStatus status) async {
    final result = await sl<SetHomeworkSubmissionStatusUseCase>().call(
      params: SetHomeworkSubmissionStatusParams(homeworkId: homeworkId, studentId: studentId, status: status),
    );
    result.fold(
      (e) => emit(state.copyWith(errorMessage: e)),
      (_) => load(),
    );
  }
}
