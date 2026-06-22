import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/debug/auth_debug.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/domain/auth/usecases/get_current_user_role.dart';
import 'package:polen_academy/presentation/splash/bloc/splash_state.dart';
import 'package:polen_academy/service_locator.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(DisplaySplash());

  void appStarted() async {
    await Future.delayed(const Duration(seconds: 2));
    await AuthDebug.log(context: 'Splash — oturum kontrolü');

    if (!sl<AuthRepository>().isLoggedIn()) {
      await AuthDebug.log(context: 'Splash → giriş yok, Welcome\'a yönlendiriliyor');
      emit(UnAuthenticated());
      return;
    }

    final role = await sl<GetCurrentUserRoleUseCase>().call();
    if (role == null || role.isEmpty) {
      await AuthDebug.log(
        context: 'Splash → oturum var ama Firestore rolü yok',
      );
      emit(UnAuthenticated());
      return;
    }

    await AuthDebug.log(context: 'Splash → giriş OK, rol: $role');
    emit(Authenticated(role));
  }
}
