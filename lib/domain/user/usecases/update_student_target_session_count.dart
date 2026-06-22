import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/service_locator.dart';

class UpdateStudentTargetSessionCountParams {
  final String studentId;
  final int targetSessionCount;

  const UpdateStudentTargetSessionCountParams({
    required this.studentId,
    required this.targetSessionCount,
  });
}

class UpdateStudentTargetSessionCountUseCase
    implements UseCase<Either<String, void>, UpdateStudentTargetSessionCountParams> {
  @override
  Future<Either<String, void>> call({
    UpdateStudentTargetSessionCountParams? params,
  }) async {
    return sl<UserRepository>().updateTargetSessionCount(
      params!.studentId,
      params.targetSessionCount,
    );
  }
}
