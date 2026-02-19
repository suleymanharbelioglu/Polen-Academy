import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_repository.dart';
import 'package:polen_academy/service_locator.dart';

class CreateHomeworkUseCase implements UseCase<Either<String, HomeworkEntity>, HomeworkEntity> {
  @override
  Future<Either<String, HomeworkEntity>> call({HomeworkEntity? params}) async {
    return sl<HomeworkRepository>().create(params!);
  }
}
