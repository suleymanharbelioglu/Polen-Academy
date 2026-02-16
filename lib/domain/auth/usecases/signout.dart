import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/service_locator.dart';

class SignoutUseCase implements UseCase<Either, dynamic> {
  @override
  Future<Either> call({dynamic params}) async {
    return sl<AuthRepository>().signOut();
  }
}
