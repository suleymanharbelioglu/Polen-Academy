import 'package:dartz/dartz.dart';
import 'package:polen_academy/core/usecase/usecase.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_repository.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/domain/homework/repository/homework_submission_repository.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/usecases/get_my_students.dart';
import 'package:polen_academy/service_locator.dart';

/// Gecikmiş ödev: verilen günü geçmiş, öğrenci tamamlamamış, koç tamamlandı/tamamlanmadı/eksik işaretlememiş.
/// Aynı listeleme yapısı için [CompletedHomeworkItem] ile uyumlu (homework, submission, studentName).
class GetOverdueHomeworksForCoachUseCase
    implements UseCase<Either<String, List<CompletedHomeworkItem>>, String> {
  static CompletedHomeworkItem _toItem(
    HomeworkEntity homework,
    HomeworkSubmissionEntity? submission,
    String studentName,
  ) {
    final sub = submission ??
        HomeworkSubmissionEntity(
          id: '${homework.id}_${homework.studentId}',
          homeworkId: homework.id,
          studentId: homework.studentId,
          status: HomeworkSubmissionStatus.pending,
          uploadedUrls: const [],
          completedAt: null,
          updatedAt: DateTime.now(),
        );
    return CompletedHomeworkItem(
      homework: homework,
      submission: sub,
      studentName: studentName,
    );
  }

  @override
  Future<Either<String, List<CompletedHomeworkItem>>> call({String? params}) async {
    final coachId = params!;
    final homeworkResult = await sl<HomeworkRepository>().getByCoachId(coachId);
    if (homeworkResult.isLeft()) {
      return homeworkResult.fold((e) => Left(e), (_) => const Right([]));
    }
    final allHomeworks = homeworkResult.fold((_) => <HomeworkEntity>[], (r) => r);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final overdueHomeworks = allHomeworks.where((h) {
      final end = DateTime(h.endDate.year, h.endDate.month, h.endDate.day);
      return end.isBefore(today);
    }).toList();
    if (overdueHomeworks.isEmpty) return const Right([]);

    final studentsResult = await sl<GetMyStudentsUseCase>().call(params: coachId);
    if (studentsResult.isLeft()) {
      return studentsResult.fold((e) => Left(e), (_) => const Right([]));
    }
    final students = studentsResult.fold((_) => <StudentEntity>[], (r) => r);
    final studentNames = <String, String>{};
    for (final s in students) {
      studentNames[s.uid] = '${s.studentName} ${s.studentSurname}';
    }

    final overdueIds = overdueHomeworks.map((h) => h.id).toList();
    // Koçun değerlendirdiği (tamamlandı / tamamlanmadı / eksik) veya öğrencinin yapıldı dediği submission'lar
    final evaluatedResult = await sl<HomeworkSubmissionRepository>().getByHomeworkIdsAndStatus(
      overdueIds,
      [
        HomeworkSubmissionStatus.approved,
        HomeworkSubmissionStatus.completedByStudent,
        HomeworkSubmissionStatus.missing,
        HomeworkSubmissionStatus.notDone,
      ],
    );
    if (evaluatedResult.isLeft()) {
      return evaluatedResult.fold((e) => Left(e), (_) => const Right([]));
    }
    final evaluated = evaluatedResult.fold((_) => <HomeworkSubmissionEntity>[], (r) => r);
    final evaluatedSet = <String>{};
    for (final s in evaluated) {
      evaluatedSet.add('${s.homeworkId}_${s.studentId}');
    }

    final pendingResult = await sl<HomeworkSubmissionRepository>().getByHomeworkIdsAndStatus(
      overdueIds,
      [HomeworkSubmissionStatus.pending],
    );
    final pendingList = pendingResult.fold((_) => <HomeworkSubmissionEntity>[], (r) => r);
    final pendingByKey = <String, HomeworkSubmissionEntity>{};
    for (final s in pendingList) {
      pendingByKey['${s.homeworkId}_${s.studentId}'] = s;
    }

    final items = <CompletedHomeworkItem>[];
    for (final h in overdueHomeworks) {
      final key = '${h.id}_${h.studentId}';
      if (evaluatedSet.contains(key)) continue;
      final name = studentNames[h.studentId] ?? 'Öğrenci';
      final sub = pendingByKey[key];
      items.add(_toItem(h, sub, name));
    }
    return Right(items);
  }
}