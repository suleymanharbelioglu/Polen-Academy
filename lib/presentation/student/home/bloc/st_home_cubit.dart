import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_submission_repository.dart';
import 'package:polen_academy/domain/homework/usecases/get_homeworks_by_student_and_date_range.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_student_and_date.dart';
import 'package:polen_academy/presentation/student/home/bloc/st_home_state.dart';
import 'package:polen_academy/service_locator.dart';

class StHomeCubit extends Cubit<StHomeState> {
  StHomeCubit({required this.studentId}) : super(const StHomeState()) {
    load();
  }

  final String studentId;

  Future<void> load() async {
    if (studentId.isEmpty) return;
    emit(state.copyWith(loading: true, errorMessage: null));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final epoch = DateTime(2000, 1, 1);

    final sessionResult = await sl<GetSessionsByStudentAndDateUseCase>().call(
      params: GetSessionsByStudentAndDateParams(studentId: studentId, date: now),
    );
    final todayHomeworkResult = await sl<GetHomeworksByStudentAndDateRangeUseCase>().call(
      params: GetHomeworksByStudentAndDateRangeParams(
        studentId: studentId,
        start: today,
        end: today,
      ),
    );
    final overdueRawResult = await sl<GetHomeworksByStudentAndDateRangeUseCase>().call(
      params: GetHomeworksByStudentAndDateRangeParams(
        studentId: studentId,
        start: epoch,
        end: yesterday,
      ),
    );

    if (isClosed) return;

    final todaySessions = sessionResult.fold((_) => <SessionEntity>[], (list) => list);
    final todayHomeworks = todayHomeworkResult.fold((_) => <HomeworkEntity>[], (list) => list);
    final overdueRaw = overdueRawResult.fold((_) => <HomeworkEntity>[], (list) => list);

    final todayItems = await _withSubmissions(todayHomeworks);
    final overdueCandidates = overdueRaw
        .where((h) => h.endDate.isBefore(today))
        .toList();
    final overdueItems = await _withSubmissions(overdueCandidates);
    // Son tarihi geçmiş tüm ödevler: yapılmamış, yaptım (onay bekliyor) ve onaylanmış dahil
    emit(state.copyWith(
      loading: false,
      todaySessions: todaySessions,
      todayHomeworkItems: todayItems,
      overdueHomeworkItems: overdueItems,
    ));
  }

  Future<List<StHomeworkItem>> _withSubmissions(List<HomeworkEntity> homeworks) async {
    final repo = sl<HomeworkSubmissionRepository>();
    final items = <StHomeworkItem>[];
    for (final h in homeworks) {
      final sub = await repo.getByHomeworkAndStudent(h.id, studentId);
      if (isClosed) return items;
      items.add(StHomeworkItem(homework: h, submission: sub.fold((_) => null, (s) => s)));
    }
    return items;
  }
}
