import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/data/auth/model/student.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/service_locator.dart';

class StudentSignupUseCase implements UseCase<Either, StudentModel> {
  @override
  Future<Either> call({StudentModel? params}) async {
    return sl<AuthRepository>().studentSignup(params!);
  }
}
