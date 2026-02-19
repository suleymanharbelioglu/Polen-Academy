import 'package:dartz/dartz.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';

abstract class HomeworkRepository {
  Future<Either<String, List<HomeworkEntity>>> getByStudentAndDateRange(
    String studentId,
    DateTime start,
    DateTime end,
  );

  Future<Either<String, List<HomeworkEntity>>> getByCoachId(String coachId);

  Future<Either<String, HomeworkEntity?>> getById(String homeworkId);

  Future<Either<String, HomeworkEntity>> create(HomeworkEntity homework);

  Future<Either<String, void>> delete(String homeworkId);
}
