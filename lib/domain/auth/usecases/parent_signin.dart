import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/data/auth/model/parent_signin_req.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/service_locator.dart';

class ParentSigninUseCase implements UseCase<Either, ParentSigninReq> {
  @override
  Future<Either> call({ParentSigninReq? params}) async {
    return sl<AuthRepository>().parentSignin(params!);
  }
}
