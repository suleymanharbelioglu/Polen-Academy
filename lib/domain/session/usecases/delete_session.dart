import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/session/repository/session_repository.dart';
import 'package:polen_academy/service_locator.dart';

class DeleteSessionUseCase implements UseCase<Either<String, void>, String> {
  @override
  Future<Either<String, void>> call({String? params}) async {
    return sl<SessionRepository>().delete(params!);
  }
}
