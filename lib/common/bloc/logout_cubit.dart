import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/bloc/logout_state.dart';
import 'package:polen_academy/domain/auth/usecases/signout.dart';
import 'package:polen_academy/service_locator.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutInitial());

  Future<void> logout() async {
    emit(LogoutLoading());

    try {
      final result = await sl<SignoutUseCase>().call();

      result.fold(
        (error) {
          print('❌ Logout hatası: $error');
          emit(LogoutFailure(errorMessage: error));
        },
        (success) {
          print('✅ Logout başarılı!');
          emit(LogoutSuccess());
        },
      );
    } catch (e) {
      print('❌ Exception: $e');
      emit(LogoutFailure(errorMessage: e.toString()));
    }
  }
}
