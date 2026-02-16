import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/data/auth/model/parent.dart';
import 'package:polen_academy/domain/auth/usecases/parent_signup.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/parent_signup_state.dart';
import 'package:polen_academy/service_locator.dart';

class ParentSignupCubit extends Cubit<ParentSignupState> {
  ParentSignupCubit() : super(ParentSignupInitial());

  void createParentFromFormData({
    required String parentName,
    required String parentSurname,
    required String coachId,
    required String studentId,
  }) {
    createParent(
      ParentModel(
        uid: '',
        parentName: parentName,
        parentSurname: parentSurname,
        email: '',
        coachId: coachId,
        studentId: studentId,
      ),
    );
  }

  Future<void> createParent(ParentModel parent) async {
    emit(ParentSignupLoading());

    try {
      final result = await sl<ParentSignupUseCase>().call(params: parent);

      result.fold(
        (error) {
          emit(ParentSignupFailure(errorMessage: error.toString()));
        },
        (success) {
          emit(ParentSignupSuccess(credentials: success));
        },
      );
    } catch (e) {
      emit(ParentSignupFailure(errorMessage: e.toString()));
    }
  }
}
