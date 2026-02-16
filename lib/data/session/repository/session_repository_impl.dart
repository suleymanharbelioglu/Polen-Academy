import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/session/model/session.dart';
import 'package:polen_academy/data/session/source/session_firebase_service.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/repository/session_repository.dart';
import 'package:polen_academy/service_locator.dart';

class SessionRepositoryImpl extends SessionRepository {
  @override
  Future<Either<String, List<SessionEntity>>> getByCoachAndDateRange(
    String coachId,
    DateTime start,
    DateTime end,
  ) async {
    final result = await sl<SessionFirebaseService>().getByCoachAndDateRange(coachId, start, end);
    return result.fold(
      (l) => Left(l),
      (list) => Right(list.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<String, List<SessionEntity>>> getByCoachAndDate(
    String coachId,
    DateTime date,
  ) async {
    final result = await sl<SessionFirebaseService>().getByCoachAndDate(coachId, date);
    return result.fold(
      (l) => Left(l),
      (list) => Right(list.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<String, SessionEntity>> create(SessionEntity session) async {
    final result = await sl<SessionFirebaseService>().create(session.toModel());
    return result.fold(
      (l) => Left(l),
      (m) => Right(m.toEntity()),
    );
  }

  @override
  Future<Either<String, void>> update(SessionEntity session) async {
    return sl<SessionFirebaseService>().update(session.toModel());
  }

  @override
  Future<Either<String, void>> delete(String sessionId) async {
    return sl<SessionFirebaseService>().delete(sessionId);
  }

  @override
  Future<Either<String, void>> updateStatus(String sessionId, SessionStatus status) async {
    return sl<SessionFirebaseService>().updateStatus(sessionId, status.name);
  }
}
