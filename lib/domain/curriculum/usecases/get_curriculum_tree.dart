import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/curriculum/repository/curriculum_repository.dart';
import 'package:polen_academy/service_locator.dart';

class GetCurriculumTreeUseCase
    implements UseCase<Either<String, CurriculumTree>, String> {
  @override
  Future<Either<String, CurriculumTree>> call({String? params}) async {
    return sl<CurriculumRepository>().getCurriculumTree(params!);
  }
}
