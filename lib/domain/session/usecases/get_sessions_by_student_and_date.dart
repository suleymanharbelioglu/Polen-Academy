import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/repository/session_repository.dart';
import 'package:polen_academy/service_locator.dart';

class GetSessionsByStudentAndDateParams {
  final String studentId;
  final DateTime date;

  const GetSessionsByStudentAndDateParams({
    required this.studentId,
    required this.date,
  });
}

class GetSessionsByStudentAndDateUseCase
    implements UseCase<Either<String, List<SessionEntity>>, GetSessionsByStudentAndDateParams> {
  @override
  Future<Either<String, List<SessionEntity>>> call({
    GetSessionsByStudentAndDateParams? params,
  }) async {
    return sl<SessionRepository>().getByStudentAndDate(params!.studentId, params.date);
  }
}
