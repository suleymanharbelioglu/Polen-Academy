import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/repository/session_repository.dart';
import 'package:polen_academy/service_locator.dart';

class GetSessionsByDateParams {
  final String coachId;
  final DateTime date;

  const GetSessionsByDateParams({
    required this.coachId,
    required this.date,
  });
}

class GetSessionsByDateUseCase
    implements UseCase<Either<String, List<SessionEntity>>, GetSessionsByDateParams> {
  @override
  Future<Either<String, List<SessionEntity>>> call({GetSessionsByDateParams? params}) async {
    return sl<SessionRepository>().getByCoachAndDate(params!.coachId, params.date);
  }
}
