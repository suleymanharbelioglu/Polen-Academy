

import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/auth/model/coach_creation_req.dart';
import 'package:polen_academy/data/auth/model/coach_signin_req.dart';

abstract class AuthRepository {
  Future<Either> coachSignup( CoachCreationReq req);
  Future<Either> coachSignin( CoachSigninReq req);
  Future<Either> signOut();

}