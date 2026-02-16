import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/service_locator.dart';

class UpdateUserPasswordParams {
  final String userId;
  final String newPassword;

  const UpdateUserPasswordParams({
    required this.userId,
    required this.newPassword,
  });
}

class UpdateUserPasswordUseCase implements UseCase<Either<String, void>, UpdateUserPasswordParams> {
  @override
  Future<Either<String, void>> call({UpdateUserPasswordParams? params}) async {
    return sl<UserRepository>().updateUserPassword(params!.userId, params.newPassword);
  }
}
