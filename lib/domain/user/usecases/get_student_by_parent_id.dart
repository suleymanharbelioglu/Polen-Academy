import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/service_locator.dart';

class GetStudentByParentIdUseCase implements UseCase<Either<String, StudentEntity?>, String> {
  @override
  Future<Either<String, StudentEntity?>> call({String? params}) async {
    return sl<UserRepository>().getStudentByParentId(params ?? '');
  }
}
