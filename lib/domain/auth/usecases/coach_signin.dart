import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/data/auth/model/coach_signin_req.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/service_locator.dart';

class CoachSigninUseCase implements UseCase<Either,CoachSigninReq> {

  @override
  Future<Either> call({CoachSigninReq ? params}) async {
    return sl<AuthRepository>().coachSignin(params!);
  }

}