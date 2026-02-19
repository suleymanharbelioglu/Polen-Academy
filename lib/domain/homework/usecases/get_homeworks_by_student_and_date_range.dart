import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_repository.dart';
import 'package:polen_academy/service_locator.dart';

class GetHomeworksByStudentAndDateRangeParams {
  final String studentId;
  final DateTime start;
  final DateTime end;

  const GetHomeworksByStudentAndDateRangeParams({
    required this.studentId,
    required this.start,
    required this.end,
  });
}

class GetHomeworksByStudentAndDateRangeUseCase
    implements UseCase<Either<String, List<HomeworkEntity>>, GetHomeworksByStudentAndDateRangeParams> {
  @override
  Future<Either<String, List<HomeworkEntity>>> call({
    GetHomeworksByStudentAndDateRangeParams? params,
  }) async {
    return sl<HomeworkRepository>().getByStudentAndDateRange(
      params!.studentId,
      params.start,
      params.end,
    );
  }
}
