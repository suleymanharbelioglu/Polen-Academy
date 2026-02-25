import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/repository/session_repository.dart';
import 'package:polen_academy/service_locator.dart';

class GetSessionsByStudentAndDateRangeParams {
  final String studentId;
  final DateTime start;
  final DateTime end;

  const GetSessionsByStudentAndDateRangeParams({
    required this.studentId,
    required this.start,
    required this.end,
  });
}

class GetSessionsByStudentAndDateRangeUseCase
    implements UseCase<Either<String, List<SessionEntity>>, GetSessionsByStudentAndDateRangeParams> {
  @override
  Future<Either<String, List<SessionEntity>>> call({
    GetSessionsByStudentAndDateRangeParams? params,
  }) async {
    return sl<SessionRepository>().getByStudentAndDateRange(
      params!.studentId,
      params.start,
      params.end,
    );
  }
}
