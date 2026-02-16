import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/data/auth/model/coach.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/service_locator.dart';

class CoachSignupUseCase implements UseCase<Either, CoachModel> {
  @override
  Future<Either> call({CoachModel? params}) async {
    return sl<AuthRepository>().coachSignup(params!);
  }
}
