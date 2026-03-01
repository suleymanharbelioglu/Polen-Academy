import 'package:dartz/dartz.dart';
import 'package:polen_academy/domain/user/entity/coach_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

abstract class UserRepository {
  Future<Either<String, CoachEntity?>> getCoachByUid(String uid);
  Future<Either<String, List<StudentEntity>>> getMyStudents(String coachId);
  Future<Either<String, StudentEntity?>> getStudentByUid(String uid);
  Future<Either<String, StudentEntity?>> getStudentByParentId(String parentId);
  Future<Either<String, void>> deleteStudent(String studentId);
  Future<Either<String, void>> updateUserPassword(String userId, String newPassword);
  Future<Either<String, void>> updateCoachVip(String coachUid, bool isVip);
}
