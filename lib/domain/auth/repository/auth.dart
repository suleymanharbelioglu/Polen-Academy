import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/auth/model/coach.dart';
import 'package:polen_academy/data/auth/model/coach_signin_req.dart';
import 'package:polen_academy/data/auth/model/parent.dart';
import 'package:polen_academy/data/auth/model/parent_signin_req.dart';
import 'package:polen_academy/data/auth/model/student.dart';
import 'package:polen_academy/data/auth/model/student_signin_req.dart';
import 'package:polen_academy/domain/auth/entity/parent_credentials_entity.dart';
import 'package:polen_academy/domain/auth/entity/student_credentials_entity.dart';

abstract class AuthRepository {
  Future<Either> coachSignup(CoachModel coach);
  Future<Either> coachSignin(CoachSigninReq req);
  Future<Either<dynamic, StudentCredentialsEntity>> studentSignup(
    StudentModel student,
  );
  Future<Either> studentSignin(StudentSigninReq req);
  Future<Either<dynamic, ParentCredentialsEntity>> parentSignup(
    ParentModel parent,
  );
  Future<Either> parentSignin(ParentSigninReq req);
  Future<Either> signOut();
  bool isLoggedIn();
  Future<String?> getCurrentUserRole();
}
