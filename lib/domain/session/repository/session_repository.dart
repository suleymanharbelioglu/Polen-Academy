import 'package:dartz/dartz.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';

abstract class SessionRepository {
  Future<Either<String, List<SessionEntity>>> getByCoachAndDateRange(
    String coachId,
    DateTime start,
    DateTime end,
  );
  Future<Either<String, List<SessionEntity>>> getByCoachAndDate(
    String coachId,
    DateTime date,
  );
  Future<Either<String, SessionEntity>> create(SessionEntity session);
  Future<Either<String, void>> update(SessionEntity session);
  Future<Either<String, void>> delete(String sessionId);
  Future<Either<String, void>> updateStatus(String sessionId, SessionStatus status);
}
