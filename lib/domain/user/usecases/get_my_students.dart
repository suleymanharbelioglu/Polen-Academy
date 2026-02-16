import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/service_locator.dart';

class GetMyStudentsUseCase
    implements UseCase<Either<String, List<StudentEntity>>, String> {
  @override
  Future<Either<String, List<StudentEntity>>> call({String? params}) async {
    return sl<UserRepository>().getMyStudents(params!);
  }
}
