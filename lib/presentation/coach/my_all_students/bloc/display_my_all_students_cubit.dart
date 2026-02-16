import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/user/usecases/get_my_students.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/display_my_all_students_state.dart';
import 'package:polen_academy/service_locator.dart';

class DisplayMyAllStudentsCubit extends Cubit<DisplayMyAllStudentsState> {
  DisplayMyAllStudentsCubit() : super(DisplayMyAllStudentsInitial());

  Future<void> getMyStudents(String coachId) async {
    emit(DisplayMyAllStudentsLoading());

    final result = await sl<GetMyStudentsUseCase>().call(params: coachId);

    result.fold(
      (error) => emit(DisplayMyAllStudentsFailure(errorMessage: error)),
      (students) => emit(DisplayMyAllStudentsSuccess(students: students)),
    );
  }
}
