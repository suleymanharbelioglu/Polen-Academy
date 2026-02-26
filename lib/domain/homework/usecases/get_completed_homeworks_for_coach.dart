import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_repository.dart';
import 'package:polen_academy/domain/homework/repository/homework_submission_repository.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/usecases/get_my_students.dart';
import 'package:polen_academy/service_locator.dart';

class CompletedHomeworkItem {
  final HomeworkEntity homework;
  final HomeworkSubmissionEntity submission;
  final String studentName;

  CompletedHomeworkItem({
    required this.homework,
    required this.submission,
    required this.studentName,
  });
}

class GetCompletedHomeworksForCoachUseCase
    implements UseCase<Either<String, List<CompletedHomeworkItem>>, String> {
  @override
  Future<Either<String, List<CompletedHomeworkItem>>> call({String? params}) async {
    final coachId = params!;
    final homeworkResult = await sl<HomeworkRepository>().getByCoachId(coachId);
    List<HomeworkEntity> homeworks;
    if (homeworkResult.isLeft()) {
      return homeworkResult.fold((e) => Left(e), (_) => const Right([]));
    }
    homeworks = homeworkResult.fold((_) => <HomeworkEntity>[], (r) => r);
    final studentsResult = await sl<GetMyStudentsUseCase>().call(params: coachId);
    if (studentsResult.isLeft()) {
      return studentsResult.fold((e) => Left(e), (_) => const Right([]));
    }
    final students = studentsResult.fold((_) => <StudentEntity>[], (r) => r);
    final studentNames = <String, String>{};
    for (final s in students) {
      studentNames[s.uid] = '${s.studentName} ${s.studentSurname}';
    }
    if (homeworks.isEmpty) return const Right([]);
    final homeworkIds = homeworks.map((h) => h.id).toList();
    // Sadece öğrencinin yapıldı dediği, koçun henüz tamamlandı/tamamlanmadı/eksik işaretlemediği ödevler
    final submissionResult = await sl<HomeworkSubmissionRepository>().getByHomeworkIdsAndStatus(
      homeworkIds,
      [HomeworkSubmissionStatus.completedByStudent],
    );
    return submissionResult.map((submissions) {
      final byHomework = <String, HomeworkEntity>{};
      for (final h in homeworks) {
        byHomework[h.id] = h;
      }
      return submissions.map((sub) {
        final homework = byHomework[sub.homeworkId]!;
        final name = studentNames[sub.studentId] ?? 'Öğrenci';
        return CompletedHomeworkItem(homework: homework, submission: sub, studentName: name);
      }).toList();
    });
  }
}
