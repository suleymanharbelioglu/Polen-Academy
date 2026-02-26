import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
import 'package:polen_academy/domain/goals/entity/topic_status.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_submission_repository.dart';
import 'package:polen_academy/domain/homework/usecases/get_homeworks_by_student_and_date_range.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_date_range.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/curriculum/usecases/get_curriculum_tree.dart';
import 'package:polen_academy/domain/goals/usecases/get_student_topic_progress.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';
import 'package:polen_academy/service_locator.dart';

class StudentDetailCubit extends Cubit<StudentDetailState> {
  StudentDetailCubit() : super(const StudentDetailState());

  Future<void> load(StudentEntity student, String coachId) async {
    emit(state.copyWith(student: student, loading: true, errorMessage: null));
    final end = DateTime.now();
    final start = end.subtract(Duration(days: state.periodDays));
    final startNorm = DateTime(start.year, start.month, start.day);
    final endNorm = DateTime(end.year, end.month, end.day);

    // Paralel: ödevler, seanslar ve müfredat ilerlemesi aynı anda
    final futureHomeworks = sl<GetHomeworksByStudentAndDateRangeUseCase>().call(
      params: GetHomeworksByStudentAndDateRangeParams(
        studentId: student.uid,
        start: startNorm,
        end: endNorm,
      ),
    );
    final endWithFuture = endNorm.add(const Duration(days: 60));
    final futureSessions = sl<GetSessionsByDateRangeUseCase>().call(
      params: GetSessionsByDateRangeParams(coachId: coachId, start: startNorm, end: endWithFuture),
    );
    final futureCourseProgress = _loadCourseProgress(student);

    final homeworkResult = await futureHomeworks;
    final homeworks = homeworkResult.fold((_) => <HomeworkEntity>[], (list) => list);

    // Tek toplu istekle bu öğrenciye ait tüm teslimleri al (N yerine 1–2 sorgu)
    final allStatuses = [
      HomeworkSubmissionStatus.pending,
      HomeworkSubmissionStatus.completedByStudent,
      HomeworkSubmissionStatus.approved,
      HomeworkSubmissionStatus.missing,
      HomeworkSubmissionStatus.notDone,
    ];
    final submissionList = homeworks.isEmpty
        ? <HomeworkSubmissionEntity>[]
        : (await sl<HomeworkSubmissionRepository>().getByHomeworkIdsAndStatus(
            homeworks.map((h) => h.id).toList(),
            allStatuses,
          )).fold((_) => <HomeworkSubmissionEntity>[], (list) => list);
    final submissionByHomeworkId = <String, HomeworkSubmissionEntity>{};
    for (final sub in submissionList) {
      if (sub.studentId == student.uid) submissionByHomeworkId[sub.homeworkId] = sub;
    }

    int overdue = 0, missing = 0, notDone = 0, completed = 0;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    for (final h in homeworks) {
      final endDay = DateTime(h.endDate.year, h.endDate.month, h.endDate.day);
      final sub = submissionByHomeworkId[h.id];
      final isCompleted = sub != null && sub.isCompleted;
      if (isCompleted) {
        completed++;
      } else {
        if (endDay.isBefore(today)) {
          overdue++;
        } else {
          if (sub?.status == HomeworkSubmissionStatus.missing) missing++;
          else if (sub?.status == HomeworkSubmissionStatus.notDone) notDone++;
          else missing++; // pending = eksik
        }
      }
    }

    final sessionResult = await futureSessions;
    final sessions = sessionResult.fold((_) => <SessionEntity>[], (list) => list);
    final studentSessions = sessions.where((s) => s.studentId == student.uid).toList();
    final completedSessions = studentSessions.where((s) => s.status == SessionStatus.completed).toList();
    final notDoneSessions = studentSessions.where((s) => s.status == SessionStatus.cancelled).toList();
    final futureSessionsList = studentSessions.where((s) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      return d.isAfter(today) && s.status == SessionStatus.scheduled;
    }).toList();
    final attended = completedSessions.length;

    final (courseProgress, overallPercent) = await futureCourseProgress;

    if (!isClosed) {
      emit(state.copyWith(
        loading: false,
        overdueCount: overdue,
        missingCount: missing,
        notDoneCount: notDone,
        completedHomeworkCount: completed,
        attendedSessionCount: attended,
        completedSessions: completedSessions,
        notDoneSessions: notDoneSessions,
        futureSessions: futureSessionsList,
        courseProgressPercent: courseProgress,
        overallProgressPercent: overallPercent,
      ));
    }
  }

  void setPeriodDays(int days) {
    if (state.periodDays == days) return;
    emit(state.copyWith(periodDays: days));
    final student = state.student;
    final coachId = student?.coachId ?? '';
    if (student != null && coachId.isNotEmpty) load(student, coachId);
  }

  /// Konu tamamlanmış sayılır: konu çalışması tamamlandı ve (tekrar tamamlandı veya hiç işaretlenmemiş).
  static bool _isTopicCompleted(StudentTopicProgressEntity? p) {
    if (p == null) return false;
    if (p.konuStatus != TopicStatus.completed) return false;
    return p.revisionStatus == TopicStatus.completed || p.revisionStatus == TopicStatus.none;
  }

  Future<(Map<String, int>, int)> _loadCourseProgress(StudentEntity student) async {
    const empty = (<String, int>{}, 0);
    final classLevel = student.studentClass;
    if (classLevel.isEmpty) return empty;
    final treeResult = await sl<GetCurriculumTreeUseCase>().call(params: classLevel);
    final progressResult = await sl<GetStudentTopicProgressUseCase>().call(params: student.uid);
    if (treeResult.isLeft() || progressResult.isLeft()) return empty;
    final tree = treeResult.fold((_) => null, (t) => t)!;
    final progressMap = progressResult.fold((_) => <String, StudentTopicProgressEntity>{}, (m) => m);
    final Map<String, int> out = {};
    int totalTopics = 0, totalDone = 0;
    for (final courseWithUnits in tree.courses) {
      int total = 0, done = 0;
      for (final unit in courseWithUnits.units) {
        for (final topic in unit.topics) {
          total++;
          totalTopics++;
          final p = progressMap[topic.id];
          if (_isTopicCompleted(p)) {
            done++;
            totalDone++;
          }
        }
      }
      if (total > 0) {
        out[courseWithUnits.course.name] = ((done / total) * 100).round().clamp(0, 100);
      }
    }
    final overallPercent = totalTopics > 0
        ? ((totalDone / totalTopics) * 100).round().clamp(0, 100)
        : 0;
    return (out, overallPercent);
  }
}
