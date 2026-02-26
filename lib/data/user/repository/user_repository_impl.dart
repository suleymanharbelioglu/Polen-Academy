import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/user/model/student.dart';
import 'package:polen_academy/data/user/source/user_firebase_service.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/service_locator.dart';

class UserRepositoryImpl extends UserRepository {
  @override
  Future<Either<String, List<StudentEntity>>> getMyStudents(
    String coachId,
  ) async {
    var students = await sl<UserFirebaseService>().getMyStudents(coachId);

    return students.fold(
      (error) => Left(error),
      (data) => Right(
        List.from(data).map((e) => StudentModel.fromMap(e).toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<String, StudentEntity?>> getStudentByUid(String uid) async {
    final result = await sl<UserFirebaseService>().getStudentByUid(uid);
    return result.fold(
      (e) => Left(e),
      (map) => Right(map != null ? StudentModel.fromMap(map).toEntity() : null),
    );
  }

  @override
  Future<Either<String, StudentEntity?>> getStudentByParentId(String parentId) async {
    final result = await sl<UserFirebaseService>().getStudentByParentId(parentId);
    return result.fold(
      (e) => Left(e),
      (map) => Right(map != null ? StudentModel.fromMap(map).toEntity() : null),
    );
  }

  @override
  Future<Either<String, void>> deleteStudent(String studentId) async {
    return sl<UserFirebaseService>().deleteStudent(studentId);
  }

  @override
  Future<Either<String, void>> updateUserPassword(String userId, String newPassword) async {
    return sl<UserFirebaseService>().updateUserPassword(userId, newPassword);
  }
}
