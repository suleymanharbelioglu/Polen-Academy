import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

class HomeState {
  final List<SessionEntity> todaySessions;
  final List<StudentEntity> students;
  final List<CompletedHomeworkItem> completedHomeworks;
  final bool loading;
  final String? errorMessage;

  const HomeState({
    this.todaySessions = const [],
    this.students = const [],
    this.completedHomeworks = const [],
    this.loading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    List<SessionEntity>? todaySessions,
    List<StudentEntity>? students,
    List<CompletedHomeworkItem>? completedHomeworks,
    bool? loading,
    String? errorMessage,
  }) {
    return HomeState(
      todaySessions: todaySessions ?? this.todaySessions,
      students: students ?? this.students,
      completedHomeworks: completedHomeworks ?? this.completedHomeworks,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}
