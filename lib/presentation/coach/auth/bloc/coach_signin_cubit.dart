import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/data/auth/model/coach_signin_req.dart';
import 'package:polen_academy/domain/auth/usecases/coach_signin.dart';
import 'package:polen_academy/domain/auth/usecases/get_current_user_role.dart';
import 'package:polen_academy/domain/auth/usecases/signout.dart';
import 'package:polen_academy/presentation/coach/auth/bloc/coach_signin_state.dart';
import 'package:polen_academy/service_locator.dart';

class CoachSigninCubit extends Cubit<CoachSigninState> {
  CoachSigninCubit() : super(CoachSigninInitial());

  Future<void> signIn(CoachSigninReq req) async {
    emit(CoachSigninLoading());

    try {
      final result = await sl<CoachSigninUseCase>().call(params: req);

      await result.fold(
        (error) async {
          emit(CoachSigninFailure(errorMessage: error));
        },
        (_) async {
          final role = await sl<GetCurrentUserRoleUseCase>().call();
          if (role != 'coach') {
            await sl<SignoutUseCase>().call();
            emit(CoachSigninFailure(
              errorMessage:
                  'Bu hesap koç hesabı değil. Lütfen kendi giriş sayfanızdan giriş yapın.',
            ));
            return;
          }
          emit(CoachSigninSuccess());
        },
      );
    } catch (e) {
      emit(CoachSigninFailure(errorMessage: e.toString()));
    }
  }
}
