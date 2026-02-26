import 'package:dartz/dartz.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

abstract class UserRepository {
  Future<Either<String, List<StudentEntity>>> getMyStudents(String coachId);
  Future<Either<String, StudentEntity?>> getStudentByUid(String uid);
  Future<Either<String, StudentEntity?>> getStudentByParentId(String parentId);
  Future<Either<String, void>> deleteStudent(String studentId);
  Future<Either<String, void>> updateUserPassword(String userId, String newPassword);
}
