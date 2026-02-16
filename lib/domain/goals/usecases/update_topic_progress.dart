import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
import 'package:polen_academy/domain/goals/repository/goals_repository.dart';
import 'package:polen_academy/service_locator.dart';

class UpdateTopicProgressUseCase
    implements UseCase<Either<String, void>, StudentTopicProgressEntity> {
  @override
  Future<Either<String, void>> call({
    StudentTopicProgressEntity? params,
  }) async {
    return sl<GoalsRepository>().updateProgress(params!);
  }
}
