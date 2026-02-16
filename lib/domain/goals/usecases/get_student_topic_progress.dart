import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
import 'package:polen_academy/domain/goals/repository/goals_repository.dart';
import 'package:polen_academy/service_locator.dart';

class GetStudentTopicProgressUseCase
    implements UseCase<Either<String, Map<String, StudentTopicProgressEntity>>, String> {
  @override
  Future<Either<String, Map<String, StudentTopicProgressEntity>>> call({
    String? params,
  }) async {
    return sl<GoalsRepository>().getProgressByStudent(params!);
  }
}
