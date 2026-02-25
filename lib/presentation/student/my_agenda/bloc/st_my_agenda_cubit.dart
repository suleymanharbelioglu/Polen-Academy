import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_student_and_date_range.dart';
import 'package:polen_academy/presentation/student/my_agenda/bloc/st_my_agenda_state.dart';
import 'package:polen_academy/service_locator.dart';

class StMyAgendaCubit extends Cubit<StMyAgendaState> {
  StMyAgendaCubit({required this.studentId})
      : super(StMyAgendaState(selectedMonth: DateTime.now()));

  final String studentId;

  Future<void> load() async {
    if (studentId.isEmpty) return;
    emit(state.copyWith(loading: true, errorMessage: null));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));
    final monthStart = DateTime(
      state.selectedMonth.year,
      state.selectedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      state.selectedMonth.year,
      state.selectedMonth.month + 1,
      0,
    );
    final monthEndPlus = lastDayOfMonth.add(const Duration(days: 7));
    final start = monthStart.isBefore(today) ? monthStart : today;
    final end = weekEnd.isAfter(monthEndPlus) ? weekEnd : monthEndPlus;
    final result = await sl<GetSessionsByStudentAndDateRangeUseCase>().call(
      params: GetSessionsByStudentAndDateRangeParams(
        studentId: studentId,
        start: start,
        end: end,
      ),
    );
    result.fold(
      (error) => emit(state.copyWith(loading: false, errorMessage: error)),
      (sessions) =>
          emit(state.copyWith(loading: false, sessionsForMonth: sessions)),
    );
  }

  void setMonth(DateTime month) {
    emit(state.copyWith(selectedMonth: DateTime(month.year, month.month)));
    load();
  }

  void previousMonth() {
    final m = state.selectedMonth;
    setMonth(DateTime(m.year, m.month - 1));
  }

  void nextMonth() {
    final m = state.selectedMonth;
    setMonth(DateTime(m.year, m.month + 1));
  }

  void selectDate(DateTime? date) {
    emit(state.copyWith(selectedDate: date, clearSelectedDate: date == null));
  }

  Future<void> refresh() => load();
}

extension _StMyAgendaStateCopy on StMyAgendaState {
  StMyAgendaState copyWith({
    DateTime? selectedMonth,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    List<SessionEntity>? sessionsForMonth,
    bool? loading,
    String? errorMessage,
  }) {
    return StMyAgendaState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
      sessionsForMonth: sessionsForMonth ?? this.sessionsForMonth,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}
