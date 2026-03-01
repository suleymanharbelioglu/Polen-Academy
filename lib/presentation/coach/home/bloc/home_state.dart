import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

class HomeState {
  final List<SessionEntity> todaySessions;
  final List<StudentEntity> students;
  /// Öğrenci uid -> genel ilerleme yüzdesi (0–100). Konu tamamlanmasından hesaplanır.
  final Map<String, int> studentProgressMap;
  final List<CompletedHomeworkItem> overdueHomeworks;
  final List<CompletedHomeworkItem> completedHomeworks;
  final bool loading;
  final String? errorMessage;

  const HomeState({
    this.todaySessions = const [],
    this.students = const [],
    this.studentProgressMap = const {},
    this.overdueHomeworks = const [],
    this.completedHomeworks = const [],
    this.loading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    List<SessionEntity>? todaySessions,
    List<StudentEntity>? students,
    Map<String, int>? studentProgressMap,
    List<CompletedHomeworkItem>? overdueHomeworks,
    List<CompletedHomeworkItem>? completedHomeworks,
    bool? loading,
    String? errorMessage,
  }) {
    return HomeState(
      todaySessions: todaySessions ?? this.todaySessions,
      students: students ?? this.students,
      studentProgressMap: studentProgressMap ?? this.studentProgressMap,
      overdueHomeworks: overdueHomeworks ?? this.overdueHomeworks,
      completedHomeworks: completedHomeworks ?? this.completedHomeworks,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}
