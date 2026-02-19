import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/homework/model/homework_model.dart';
import 'package:polen_academy/data/homework/source/homework_firebase_service.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_repository.dart';

class HomeworkRepositoryImpl extends HomeworkRepository {
  HomeworkRepositoryImpl(this._service);
  final HomeworkFirebaseService _service;

  @override
  Future<Either<String, List<HomeworkEntity>>> getByStudentAndDateRange(
    String studentId,
    DateTime start,
    DateTime end,
  ) async {
    final result = await _service.getByStudentAndDateRange(studentId, start, end);
    return result.map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<String, List<HomeworkEntity>>> getByCoachId(String coachId) async {
    final result = await _service.getByCoachId(coachId);
    return result.map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<String, HomeworkEntity?>> getById(String homeworkId) async {
    final result = await _service.getById(homeworkId);
    return result.map((m) => m?.toEntity());
  }

  @override
  Future<Either<String, HomeworkEntity>> create(HomeworkEntity homework) async {
    final model = homework.toModel();
    final result = await _service.create(model);
    return result.map((m) => m.toEntity());
  }

  @override
  Future<Either<String, void>> delete(String homeworkId) async {
    return _service.delete(homeworkId);
  }
}
