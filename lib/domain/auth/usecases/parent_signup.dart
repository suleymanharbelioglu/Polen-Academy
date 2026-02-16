import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/data/auth/model/parent.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/service_locator.dart';

class ParentSignupUseCase implements UseCase<Either, ParentModel> {
  @override
  Future<Either> call({ParentModel? params}) async {
    return sl<AuthRepository>().parentSignup(params!);
  }
}
