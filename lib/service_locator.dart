import 'package:get_it/get_it.dart';
import 'package:polen_academy/data/auth/repository/auth_repository_impl.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/domain/auth/usecases/coach_signin.dart';
import 'package:polen_academy/domain/auth/usecases/coach_signup.dart';
import 'package:polen_academy/domain/auth/usecases/signout.dart';

final sl = GetIt.instance;
Future<void> initializeDependencies() async {
  // Services

  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());

  // Repositories

  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  // Usecases
  sl.registerSingleton<CoachSignupUseCase>(CoachSignupUseCase());
  sl.registerSingleton<CoachSigninUseCase>(CoachSigninUseCase());
  sl.registerSingleton<SignoutUseCase>(SignoutUseCase());
}
