import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/data/auth/model/student.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/auth/usecases/student_signup.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/student_creation_req_state.dart';
import 'package:polen_academy/service_locator.dart';

class StudentCreationReqCubit extends Cubit<StudentCreationReqState> {
  StudentCreationReqCubit() : super(StudentCreationReqInitial());

  void createStudentFromFormData(Map<String, dynamic> data) {
    final coachUid = sl<AuthFirebaseService>().getCurrentUserUid();
    if (coachUid == null) {
      emit(StudentCreationReqFailure(errorMessage: 'Koç bilgisi alınamadı. Lütfen tekrar giriş yapın.'));
      return;
    }
    final focusIds = (data['focusCourseIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[];
    final student = StudentModel(
      uid: '',
      studentName: data['firstName'] ?? '',
      studentSurname: data['lastName'] ?? '',
      email: '',
      studentClass: data['classLevel'] ?? '1. Sınıf',
      coachId: coachUid,
      parentId: '',
      progress: 0,
      hasParent: false,
      focusCourseIds: focusIds,
    );
    createStudent(student);
  }

  Future<void> createStudent(StudentModel student) async {
    emit(StudentCreationReqLoading());

    try {
      final result = await sl<StudentSignupUseCase>().call(params: student);

      result.fold(
        (error) {
          emit(StudentCreationReqFailure(errorMessage: error));
        },
        (success) {
          emit(StudentCreationReqSuccess(credentials: success));
        },
      );
    } catch (e) {
      emit(StudentCreationReqFailure(errorMessage: e.toString()));
    }
  }
}
