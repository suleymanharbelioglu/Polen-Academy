import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/domain/homework/usecases/get_overdue_homeworks_for_coach.dart';
import 'package:polen_academy/domain/goals/usecases/revert_topic_progress_for_homework.dart';
import 'package:polen_academy/domain/goals/usecases/sync_topic_progress_from_homework.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/notification/usecases/notify_homework_status_by_coach.dart';
import 'package:polen_academy/domain/notification/usecases/notify_overdue_to_parent.dart';
import 'package:polen_academy/domain/notification/usecases/notify_session_status.dart';
import 'package:polen_academy/domain/homework/usecases/set_homework_submission_status.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_date.dart';
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
    final overdueResult = await sl<GetOverdueHomeworksForCoachUseCase>().call(params: coachId);
    final completedResult = await sl<GetCompletedHomeworksForCoachUseCase>().call(params: coachId);
    if (isClosed) return;

    final todaySessions = sessionResult.fold((_) => <SessionEntity>[], (list) => list);
    final students = studentsResult.fold((_) => state.students, (list) => list);
    final overdue = overdueResult.fold((_) => state.overdueHomeworks, (list) => list);
    final completed = completedResult.fold((_) => state.completedHomeworks, (list) => list);
    final errorMessage = sessionResult.fold(
      (e) => e,
      (_) => studentsResult.fold(
        (e) => e,
        (_) => overdueResult.fold(
          (e) => e,
          (_) => completedResult.fold((e) => e, (_) => null),
        ),
      ),
    );
    emit(state.copyWith(
      loading: false,
      todaySessions: todaySessions,
      students: students,
      overdueHomeworks: overdue,
      completedHomeworks: completed,
      errorMessage: errorMessage,
    ));
    for (final item in overdue) {
      sl<NotifyOverdueToParentUseCase>().call(
        params: NotifyOverdueToParentParams(
          studentId: item.submission.studentId,
          studentName: item.studentName,
          homeworkId: item.homework.id,
          courseName: item.homework.courseName,
        ),
      );
    }
  }

  Future<void> approveSession(String sessionId, [String? statusNote]) async {
    final result = await sl<UpdateSessionStatusUseCase>().call(
      params: UpdateSessionStatusParams(sessionId: sessionId, status: SessionStatus.completed, statusNote: statusNote),
    );
    result.fold(
      (e) => emit(state.copyWith(errorMessage: e)),
      (_) async {
        SessionEntity? session;
        for (final s in state.todaySessions) {
          if (s.id == sessionId) { session = s; break; }
        }
        if (session != null) {
          await sl<NotifySessionStatusUseCase>().call(
            params: NotifySessionStatusParams(
              sessionId: sessionId,
              studentId: session.studentId,
              studentName: session.studentName,
              date: session.date,
              startTime: session.startTime,
              isCompleted: true,
            ),
          );
        }
        load();
      },
    );
  }

  Future<void> cancelSession(String sessionId, [String? statusNote]) async {
    final result = await sl<UpdateSessionStatusUseCase>().call(
      params: UpdateSessionStatusParams(sessionId: sessionId, status: SessionStatus.cancelled, statusNote: statusNote),
    );
    result.fold(
      (e) => emit(state.copyWith(errorMessage: e)),
      (_) async {
        SessionEntity? session;
        for (final s in state.todaySessions) {
          if (s.id == sessionId) { session = s; break; }
        }
        if (session != null) {
          await sl<NotifySessionStatusUseCase>().call(
            params: NotifySessionStatusParams(
              sessionId: sessionId,
              studentId: session.studentId,
              studentName: session.studentName,
              date: session.date,
              startTime: session.startTime,
              isCompleted: false,
            ),
          );
        }
        load();
      },
    );
  }

  Future<void> setSubmissionStatus(String homeworkId, String studentId, HomeworkSubmissionStatus status) async {
    final result = await sl<SetHomeworkSubmissionStatusUseCase>().call(
      params: SetHomeworkSubmissionStatusParams(homeworkId: homeworkId, studentId: studentId, status: status),
    );
    result.fold(
      (e) => emit(state.copyWith(errorMessage: e)),
      (_) async {
        if (status == HomeworkSubmissionStatus.pending) {
          await sl<RevertTopicProgressForHomeworkUseCase>().call(
            params: RevertTopicProgressForHomeworkParams(
              homeworkId: homeworkId,
              studentId: studentId,
            ),
          );
        } else {
          await sl<SyncTopicProgressFromHomeworkUseCase>().call(
            params: SyncTopicProgressFromHomeworkParams(
              homeworkId: homeworkId,
              studentId: studentId,
              status: status,
            ),
          );
        }
        CompletedHomeworkItem? item;
        for (final i in state.completedHomeworks) {
          if (i.homework.id == homeworkId && i.submission.studentId == studentId) {
            item = i;
            break;
          }
        }
        final courseName = item?.homework.courseName;
        await sl<NotifyHomeworkStatusByCoachUseCase>().call(
          params: NotifyHomeworkStatusByCoachParams(
            studentId: studentId,
            homeworkId: homeworkId,
            status: status,
            courseName: courseName,
          ),
        );
        load();
      },
    );
  }
}
