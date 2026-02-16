import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/repository/session_repository.dart';
import 'package:polen_academy/service_locator.dart';

class GetSessionsByDateRangeParams {
  final String coachId;
  final DateTime start;
  final DateTime end;

  const GetSessionsByDateRangeParams({
    required this.coachId,
    required this.start,
    required this.end,
  });
}

class GetSessionsByDateRangeUseCase
    implements UseCase<Either<String, List<SessionEntity>>, GetSessionsByDateRangeParams> {
  @override
  Future<Either<String, List<SessionEntity>>> call({GetSessionsByDateRangeParams? params}) async {
    return sl<SessionRepository>().getByCoachAndDateRange(
      params!.coachId,
      params.start,
      params.end,
    );
  }
}
