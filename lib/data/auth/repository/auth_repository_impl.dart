import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/auth/model/coach.dart';
import 'package:polen_academy/data/auth/model/coach_signin_req.dart';
import 'package:polen_academy/data/auth/model/parent.dart';
import 'package:polen_academy/data/auth/model/parent_creation_result.dart';
import 'package:polen_academy/data/auth/model/parent_signin_req.dart';
import 'package:polen_academy/data/auth/model/student.dart';
import 'package:polen_academy/data/auth/model/student_creation_result.dart';
import 'package:polen_academy/data/auth/model/student_signin_req.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/auth/entity/parent_credentials_entity.dart';
import 'package:polen_academy/domain/auth/entity/student_credentials_entity.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either<dynamic, dynamic>> coachSignin(CoachSigninReq req) async {
    return await sl<AuthFirebaseService>().coachSignin(req);
  }

  @override
  Future<Either<dynamic, dynamic>> coachSignup(CoachModel coach) async {
    return await sl<AuthFirebaseService>().coachSignup(coach);
  }

  @override
  Future<Either<dynamic, dynamic>> signOut() async {
    return await sl<AuthFirebaseService>().signOut();
  }

  @override
  Future<Either<dynamic, StudentCredentialsEntity>> studentSignup(
    StudentModel student,
  ) async {
    final result = await sl<AuthFirebaseService>().studentSignup(student);
    return result.fold(
      (l) => Left(l),
      (r) {
        final model = r as StudentCreationResult;
        return Right(StudentCredentialsEntity(
          email: model.email,
          password: model.password,
        ));
      },
    );
  }

  @override
  Future<Either<dynamic, dynamic>> studentSignin(StudentSigninReq req) async {
    return await sl<AuthFirebaseService>().studentSignin(req);
  }

  @override
  Future<Either<dynamic, ParentCredentialsEntity>> parentSignup(
    ParentModel parent,
  ) async {
    final result = await sl<AuthFirebaseService>().parentSignup(parent);
    return result.fold(
      (l) => Left(l),
      (r) {
        final model = r as ParentCreationResult;
        return Right(ParentCredentialsEntity(
          email: model.email,
          password: model.password,
          parentUid: model.uid,
        ));
      },
    );
  }

  @override
  Future<Either<dynamic, dynamic>> parentSignin(ParentSigninReq req) async {
    return await sl<AuthFirebaseService>().parentSignin(req);
  }

  @override
  bool isLoggedIn() => sl<AuthFirebaseService>().isLoggedIn();

  @override
  Future<Either<String, void>> sendPasswordResetEmail(String email) =>
      sl<AuthFirebaseService>().sendPasswordResetEmail(email);

  @override
  Future<String?> getCurrentUserRole() =>
      sl<AuthFirebaseService>().getCurrentUserRole();
}
