import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/open_student_detail_state.dart';

class OpenStudentDetailCubit extends Cubit<OpenStudentDetailState> {
  OpenStudentDetailCubit() : super(OpenStudentDetailInitial());

  void requestOpen() => emit(OpenStudentDetailRequested());

  void reset() => emit(OpenStudentDetailInitial());
}
