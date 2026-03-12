import 'package:polen_academy/core/utils/session_list_helper.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';

class SessionDetailState {
  const SessionDetailState({
    this.student,
    this.rangeFilter = StudentDetailRangeFilter.all,
    this.sessions = const [],
    this.loading = true,
    this.error,
  });

  final StudentEntity? student;
  final StudentDetailRangeFilter rangeFilter;
  final List<SessionEntity> sessions;
  final bool loading;
  final String? error;

  List<SessionEntity> get completedSessions =>
      SessionListHelper.completed(sessions);

  List<SessionEntity> get notDoneSessions =>
      SessionListHelper.notDone(sessions);

  List<SessionEntity> get futureSessions =>
      SessionListHelper.future(sessions);

  int get completedCount => completedSessions.length;
  int get notDoneCount => notDoneSessions.length;
  int get futureCount => futureSessions.length;

  SessionDetailState copyWith({
    StudentEntity? student,
    StudentDetailRangeFilter? rangeFilter,
    List<SessionEntity>? sessions,
    bool? loading,
    String? error,
  }) {
    return SessionDetailState(
      student: student ?? this.student,
      rangeFilter: rangeFilter ?? this.rangeFilter,
      sessions: sessions ?? this.sessions,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
