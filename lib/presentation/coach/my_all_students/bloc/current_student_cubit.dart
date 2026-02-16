import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

/// Cubit that stores the currently selected student entity. State is [StudentEntity?].
class CurrentStudentCubit extends Cubit<StudentEntity?> {
  CurrentStudentCubit() : super(null);

  void setStudent(StudentEntity student) {
    emit(student);
  }

  void clearStudent() {
    emit(null);
  }
}
