import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/presentation/splash/bloc/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(DisplaySplash());

  void appStarted() async {
    await Future.delayed(Duration(seconds: 3));
    // var isLoggedIn = await sl<IsLoggedInUseCase>().call();
    // if (isLoggedIn) {
    //   emit(Authenticated());
    // } else {
    //   emit(UnAuthenticated());
    // }
    // emit(Authenticated());
    emit(UnAuthenticated());
  }
}
