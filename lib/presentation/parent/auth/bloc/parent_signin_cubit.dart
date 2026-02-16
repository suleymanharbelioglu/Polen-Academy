import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/data/auth/model/parent_signin_req.dart';
import 'package:polen_academy/domain/auth/usecases/get_current_user_role.dart';
import 'package:polen_academy/domain/auth/usecases/parent_signin.dart';
import 'package:polen_academy/domain/auth/usecases/signout.dart';
import 'package:polen_academy/presentation/parent/auth/bloc/parent_signin_state.dart';
import 'package:polen_academy/service_locator.dart';

class ParentSigninCubit extends Cubit<ParentSigninState> {
  ParentSigninCubit() : super(ParentSigninInitial());

  Future<void> signIn(ParentSigninReq req) async {
    emit(ParentSigninLoading());

    try {
      final result = await sl<ParentSigninUseCase>().call(params: req);

      await result.fold(
        (error) async {
          emit(ParentSigninFailure(errorMessage: error));
        },
        (_) async {
          final role = await sl<GetCurrentUserRoleUseCase>().call();
          if (role != 'parent') {
            await sl<SignoutUseCase>().call();
            emit(ParentSigninFailure(
              errorMessage:
                  'Bu hesap veli hesabı değil. Lütfen kendi giriş sayfanızdan giriş yapın.',
            ));
            return;
          }
          emit(ParentSigninSuccess());
        },
      );
    } catch (e) {
      emit(ParentSigninFailure(errorMessage: e.toString()));
    }
  }
}
