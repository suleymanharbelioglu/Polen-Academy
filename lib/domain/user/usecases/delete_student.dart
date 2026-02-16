import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/service_locator.dart';

class DeleteStudentUseCase implements UseCase<Either<String, void>, String> {
  @override
  Future<Either<String, void>> call({String? params}) async {
    return sl<UserRepository>().deleteStudent(params!);
  }
}
