

import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/auth/model/coach_creation_req.dart';
import 'package:polen_academy/data/auth/model/coach_signin_req.dart';

abstract class AuthFirebaseService {
  Future<Either> coachSignup( CoachCreationReq req);
  Future<Either> coachSignin( CoachSigninReq req);
  Future<Either> signOut();
 
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  @override
  Future<Either<dynamic, dynamic>> coachSignup(CoachCreationReq req) {
    // TODO: implement coachSignup
    throw UnimplementedError();
  }
  
  @override
  Future<Either<dynamic, dynamic>> coachSignin(CoachSigninReq req) {
    // TODO: implement coachSignin
    throw UnimplementedError();
  }
  
  @override
  Future<Either<dynamic, dynamic>> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }
  
}
