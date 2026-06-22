import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/session/repository/session_repository.dart';
import 'package:polen_academy/service_locator.dart';

class GetCompletedSessionCountUseCase
    implements UseCase<Either<String, int>, String> {
  @override
  Future<Either<String, int>> call({String? params}) async {
    return sl<SessionRepository>().getCompletedCountByStudent(params ?? '');
  }
}
