import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/request_add_student_state.dart';

class RequestAddStudentCubit extends Cubit<RequestAddStudentState> {
  RequestAddStudentCubit() : super(RequestAddStudentInitial());

  void requestOpen() => emit(RequestAddStudentOpenDialog());

  void reset() => emit(RequestAddStudentInitial());
}
