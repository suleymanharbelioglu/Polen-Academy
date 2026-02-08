import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/data/auth/model/coach_creation_req.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/presentation/service_locator.dart';

class CoachSignupUseCase implements UseCase<Either, CoachCreationReq> {
  @override
  Future<Either> call({CoachCreationReq? params}) async {
    return sl<AuthRepository>().coachSignup(params!);
  }
}
