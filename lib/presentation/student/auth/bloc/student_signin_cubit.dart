import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/data/auth/model/student_signin_req.dart';
import 'package:polen_academy/domain/auth/usecases/get_current_user_role.dart';
import 'package:polen_academy/domain/auth/usecases/signout.dart';
import 'package:polen_academy/domain/auth/usecases/student_signin.dart';
import 'package:polen_academy/presentation/student/auth/bloc/student_signin_state.dart';
import 'package:polen_academy/service_locator.dart';

class StudentSigninCubit extends Cubit<StudentSigninState> {
  StudentSigninCubit() : super(StudentSigninInitial());

  Future<void> signIn(StudentSigninReq req) async {
    emit(StudentSigninLoading());

    try {
      final result = await sl<StudentSigninUseCase>().call(params: req);

      await result.fold(
        (error) async {
          emit(StudentSigninFailure(errorMessage: error));
        },
        (_) async {
          final role = await sl<GetCurrentUserRoleUseCase>().call();
          if (role != 'student') {
            await sl<SignoutUseCase>().call();
            emit(StudentSigninFailure(
              errorMessage:
                  'Bu hesap öğrenci hesabı değil. Lütfen kendi giriş sayfanızdan giriş yapın.',
            ));
            return;
          }
          emit(StudentSigninSuccess());
        },
      );
    } catch (e) {
      emit(StudentSigninFailure(errorMessage: e.toString()));
    }
  }
}
