import 'package:get_it/get_it.dart';
import 'package:polen_academy/data/auth/repository/auth_repository_impl.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/data/session/repository/session_repository_impl.dart';
import 'package:polen_academy/data/session/source/session_firebase_service.dart';
import 'package:polen_academy/data/user/repository/user_repository_impl.dart';
import 'package:polen_academy/data/user/source/user_firebase_service.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/domain/auth/usecases/coach_signin.dart';
import 'package:polen_academy/domain/auth/usecases/coach_signup.dart';
import 'package:polen_academy/domain/auth/usecases/get_current_user_role.dart';
import 'package:polen_academy/domain/auth/usecases/signout.dart';
import 'package:polen_academy/domain/auth/usecases/parent_signin.dart';
import 'package:polen_academy/domain/auth/usecases/parent_signup.dart';
import 'package:polen_academy/domain/auth/usecases/student_signin.dart';
import 'package:polen_academy/domain/auth/usecases/student_signup.dart';
import 'package:polen_academy/domain/session/repository/session_repository.dart';
import 'package:polen_academy/domain/session/usecases/create_session.dart';
import 'package:polen_academy/domain/session/usecases/delete_session.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_date.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_date_range.dart';
import 'package:polen_academy/domain/session/usecases/update_session.dart';
import 'package:polen_academy/domain/session/usecases/update_session_status.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/domain/user/usecases/delete_student.dart';
import 'package:polen_academy/domain/user/usecases/get_my_students.dart';
import 'package:polen_academy/domain/user/usecases/update_user_password.dart';

final sl = GetIt.instance;
Future<void> initializeDependencies() async {
  // Services
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  sl.registerSingleton<UserFirebaseService>(UserFirebaseServiceImpl());
  sl.registerSingleton<SessionFirebaseService>(SessionFirebaseServiceImpl());

  // Repositories
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  sl.registerSingleton<UserRepository>(UserRepositoryImpl());
  sl.registerSingleton<SessionRepository>(SessionRepositoryImpl());

  // Auth Usecases
  sl.registerSingleton<CoachSignupUseCase>(CoachSignupUseCase());
  sl.registerSingleton<CoachSigninUseCase>(CoachSigninUseCase());
  sl.registerSingleton<StudentSignupUseCase>(StudentSignupUseCase());
  sl.registerSingleton<StudentSigninUseCase>(StudentSigninUseCase());
  sl.registerSingleton<ParentSignupUseCase>(ParentSignupUseCase());
  sl.registerSingleton<ParentSigninUseCase>(ParentSigninUseCase());
  sl.registerSingleton<SignoutUseCase>(SignoutUseCase());
  sl.registerSingleton<GetCurrentUserRoleUseCase>(GetCurrentUserRoleUseCase());

  // User Usecases
  sl.registerSingleton<GetMyStudentsUseCase>(GetMyStudentsUseCase());
  sl.registerSingleton<DeleteStudentUseCase>(DeleteStudentUseCase());
  sl.registerSingleton<UpdateUserPasswordUseCase>(UpdateUserPasswordUseCase());

  // Session Usecases
  sl.registerSingleton<GetSessionsByDateRangeUseCase>(GetSessionsByDateRangeUseCase());
  sl.registerSingleton<GetSessionsByDateUseCase>(GetSessionsByDateUseCase());
  sl.registerSingleton<CreateSessionUseCase>(CreateSessionUseCase());
  sl.registerSingleton<UpdateSessionUseCase>(UpdateSessionUseCase());
  sl.registerSingleton<DeleteSessionUseCase>(DeleteSessionUseCase());
  sl.registerSingleton<UpdateSessionStatusUseCase>(UpdateSessionStatusUseCase());
}
