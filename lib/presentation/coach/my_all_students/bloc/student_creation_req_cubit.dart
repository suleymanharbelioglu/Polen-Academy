import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/debug/create_student_debug.dart';
import 'package:polen_academy/data/auth/model/student.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/auth/usecases/student_signup.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/student_creation_req_state.dart';
import 'package:polen_academy/service_locator.dart';

class StudentCreationReqCubit extends Cubit<StudentCreationReqState> {
  StudentCreationReqCubit() : super(StudentCreationReqInitial());

  void createStudentFromFormData(Map<String, dynamic> data) {
    CreateStudentDebug.section('Form gönderildi');
    CreateStudentDebug.log('formData keys: ${data.keys.toList()}');

    final coachUid = sl<AuthFirebaseService>().getCurrentUserUid();
    CreateStudentDebug.log('getCurrentUserUid(): ${coachUid ?? "NULL"}');

    if (coachUid == null) {
      CreateStudentDebug.log('DURDU → coachUid null, Cloud Function çağrılmayacak');
      emit(StudentCreationReqFailure(errorMessage: 'Koç bilgisi alınamadı. Lütfen tekrar giriş yapın.'));
      return;
    }
    final focusIds = (data['focusCourseIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[];
    final academicField = data['academicField'] as String?;
    final targetSessionCount = data['targetSessionCount'] as int?;
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
      academicField: academicField != null && academicField.isNotEmpty ? academicField : null,
      targetSessionCount: targetSessionCount,
    );
    createStudent(student);
  }

  Future<void> createStudent(StudentModel student) async {
    emit(StudentCreationReqLoading());
    CreateStudentDebug.section('createStudent başladı');
    await CreateStudentDebug.logAuthSnapshot('cubit — createStudent');
    await CreateStudentDebug.logCoachRole(student.coachId);

    try {
      final result = await sl<StudentSignupUseCase>().call(params: student);

      result.fold(
        (error) {
          CreateStudentDebug.log('SONUÇ → HATA: $error');
          emit(StudentCreationReqFailure(errorMessage: error));
        },
        (success) {
          CreateStudentDebug.log('SONUÇ → BAŞARILI, email=${success.email}');
          emit(StudentCreationReqSuccess(credentials: success));
        },
      );
    } catch (e, st) {
      CreateStudentDebug.logGenericError(e, st);
      emit(StudentCreationReqFailure(errorMessage: e.toString()));
    }
  }
}
