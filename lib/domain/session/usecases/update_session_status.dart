import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/repository/session_repository.dart';
import 'package:polen_academy/service_locator.dart';

class UpdateSessionStatusParams {
  final String sessionId;
  final SessionStatus status;
  final String? statusNote;

  const UpdateSessionStatusParams({
    required this.sessionId,
    required this.status,
    this.statusNote,
  });
}

class UpdateSessionStatusUseCase
    implements UseCase<Either<String, void>, UpdateSessionStatusParams> {
  @override
  Future<Either<String, void>> call({UpdateSessionStatusParams? params}) async {
    return sl<SessionRepository>().updateStatus(
      params!.sessionId,
      params.status,
      params.statusNote,
    );
  }
}
