import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/data/auth/model/student_signin_req.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/service_locator.dart';

class StudentSigninUseCase implements UseCase<Either, StudentSigninReq> {
  @override
  Future<Either> call({StudentSigninReq? params}) async {
    return sl<AuthRepository>().studentSignin(params!);
  }
}
