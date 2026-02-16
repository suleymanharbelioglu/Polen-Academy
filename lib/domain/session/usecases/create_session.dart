import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/repository/session_repository.dart';
import 'package:polen_academy/service_locator.dart';

class CreateSessionUseCase implements UseCase<Either<String, SessionEntity>, SessionEntity> {
  @override
  Future<Either<String, SessionEntity>> call({SessionEntity? params}) async {
    return sl<SessionRepository>().create(params!);
  }
}
