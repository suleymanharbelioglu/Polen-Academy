import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_date_range.dart';
import 'package:polen_academy/presentation/coach/my_agenda/bloc/my_agenda_state.dart';
import 'package:polen_academy/service_locator.dart';

class MyAgendaCubit extends Cubit<MyAgendaState> {
  MyAgendaCubit({required this.coachId})
      : super(MyAgendaState(selectedMonth: DateTime.now()));

  final String coachId;

  Future<void> load() async {
    if (coachId.isEmpty) return;
    emit(state.copyWith(loading: true, errorMessage: null));
    final start = DateTime(state.selectedMonth.year, state.selectedMonth.month, 1);
    final end = DateTime(state.selectedMonth.year, state.selectedMonth.month + 1, 0);
    final result = await sl<GetSessionsByDateRangeUseCase>().call(
      params: GetSessionsByDateRangeParams(
        coachId: coachId,
        start: start,
        end: end,
      ),
    );
    result.fold(
      (error) => emit(state.copyWith(
        loading: false,
        errorMessage: error,
      )),
      (sessions) => emit(state.copyWith(
        loading: false,
        sessionsForMonth: sessions,
      )),
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

  Future<void> refresh() => load();
}

extension _MyAgendaStateCopy on MyAgendaState {
  MyAgendaState copyWith({
    DateTime? selectedMonth,
    List<SessionEntity>? sessionsForMonth,
    bool? loading,
    String? errorMessage,
  }) {
    return MyAgendaState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      sessionsForMonth: sessionsForMonth ?? this.sessionsForMonth,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}
