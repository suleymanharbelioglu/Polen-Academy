import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/utils/homework_ui_helper.dart';
import 'package:polen_academy/core/utils/student_detail_range_helper.dart';
import 'package:polen_academy/domain/goals/entity/student_topic_progress_entity.dart';
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
    emit(state.copyWith(
      student: student,
      loading: true,
      errorMessage: null,
      detailedProgressLoaded: false,
    ));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = StudentDetailRangeHelper.rangeStart(
      state.rangeFilter,
      student,
      now,
    );
    final startNorm = DateTime(start.year, start.month, start.day);
    final endNorm = StudentDetailRangeHelper.rangeEnd(state.rangeFilter, now);
    final endWithFuture = StudentDetailRangeHelper.sessionQueryEnd(now);

    final futureHomeworks = sl<GetHomeworksByStudentAndDateRangeUseCase>().call(
      params: GetHomeworksByStudentAndDateRangeParams(
        studentId: student.uid,
        start: startNorm,
        end: endNorm,
      ),
    );
    final futureSessions = sl<GetSessionsByDateRangeUseCase>().call(
      params: GetSessionsByDateRangeParams(
        coachId: coachId,
        start: startNorm,
        end: endWithFuture,
      ),
    );
    // Ayrıntılı müfredat + konu ilerlemesi hesaplamasını arka planda yap.
    _loadCourseProgress(student);

    final homeworkResult = await futureHomeworks;
    final homeworks = homeworkResult.fold(
      (_) => <HomeworkEntity>[],
      (list) => list,
    );

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
      if (sub.studentId == student.uid)
        submissionByHomeworkId[sub.homeworkId] = sub;
    }

    final overdue = HomeworkUiHelper.filterOverdue(homeworks, submissionByHomeworkId).length;
    final missing = HomeworkUiHelper.filterMissing(homeworks, submissionByHomeworkId).length;
    final notDone = HomeworkUiHelper.filterNotDone(homeworks, submissionByHomeworkId).length;
    final completed = HomeworkUiHelper.filterCompleted(homeworks, submissionByHomeworkId).length;

    final sessionResult = await futureSessions;
    final sessions = sessionResult.fold(
      (_) => <SessionEntity>[],
      (list) => list,
    );
    final studentSessions = sessions
        .where((s) => s.studentId == student.uid)
        .toList();
    final completedSessions = studentSessions
        .where((s) => s.status == SessionStatus.completed)
        .toList();
    final notDoneSessions = studentSessions
        .where((s) => s.status == SessionStatus.cancelled)
        .toList();
    final futureSessionsList = studentSessions.where((s) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      return d.isAfter(today) && s.status == SessionStatus.scheduled;
    }).toList();
    final attended = completedSessions.length;

    if (!isClosed) {
      emit(
        state.copyWith(
          loading: false,
          overdueCount: overdue,
          missingCount: missing,
          notDoneCount: notDone,
          completedHomeworkCount: completed,
          attendedSessionCount: attended,
          completedSessions: completedSessions,
          notDoneSessions: notDoneSessions,
          futureSessions: futureSessionsList,
          // İlk aşamada hızlı yükleme için, ayrıntılı konu hesabı yerine
          // doğrudan öğrencinin kendi progress alanını kullan.
          courseProgressPercent: const {},
          overallProgressPercent: student.progress.clamp(0, 100),
        ),
      );
    }
  }

  void setRangeFilter(StudentDetailRangeFilter filter) {
    if (state.rangeFilter == filter) return;
    emit(state.copyWith(rangeFilter: filter));
    final student = state.student;
    final coachId = student?.coachId ?? '';
    if (student != null && coachId.isNotEmpty) load(student, coachId);
  }

  Future<void> _loadCourseProgress(
    StudentEntity student,
  ) async {
    final classLevel = student.studentClass;
    if (classLevel.isEmpty) return;

    final progressResult = await sl<GetStudentTopicProgressUseCase>().call(
      params: student.uid,
    );
    if (progressResult.isLeft()) return;
    final progressMap = progressResult.fold(
      (_) => <String, StudentTopicProgressEntity>{},
      (m) => m,
    );

    final Map<String, int> courseOut = {};
    final Map<String, int> examOut = {};
    int overallTotalTopics = 0;
    double overallTotalContribution = 0;

    // Yardımcı: belirli müfredat seviyesi ve isteğe bağlı prefix filtresiyle ilerleme hesapla.
    Future<void> computeForLevel(String level, {String? courseIdPrefix, String? examKey}) async {
      final treeResult = await sl<GetCurriculumTreeUseCase>().call(params: level);
      if (treeResult.isLeft()) return;
      final tree = treeResult.fold((_) => null, (t) => t)!;
      int levelTotalTopics = 0;
      double levelTotalContribution = 0;
      for (final courseWithUnits in tree.courses) {
        if (courseIdPrefix != null &&
            !courseWithUnits.course.id.startsWith(courseIdPrefix)) {
          continue;
        }
        int total = 0;
        double courseContribution = 0;
        for (final unit in courseWithUnits.units) {
          for (final topic in unit.topics) {
            total++;
            levelTotalTopics++;
            overallTotalTopics++;
            final p = progressMap[topic.id];
            final c = StudentTopicProgressEntity.progressContribution(p);
            courseContribution += c;
            levelTotalContribution += c;
            overallTotalContribution += c;
          }
        }
        if (total > 0) {
          final key =
              examKey != null ? '$examKey - ${courseWithUnits.course.name}' : courseWithUnits.course.name;
          courseOut[key] = ((courseContribution / total) * 100)
              .round()
              .clamp(0, 100);
        }
      }
      if (examKey != null && levelTotalTopics > 0) {
        examOut[examKey] = ((levelTotalContribution / levelTotalTopics) * 100)
            .round()
            .clamp(0, 100);
      }
    }

    // 11 / 12 / Mezun için sınav bazlı; diğerleri için sadece sınıf seviyesine göre.
    bool hasPrefix(String prefix) =>
        student.focusCourseIds.any((id) => id.startsWith(prefix));

    if (classLevel == '11. Sınıf' ||
        classLevel == '12. Sınıf' ||
        classLevel == 'Mezun') {
      // 11. sınıf dersi
      if (classLevel == '11. Sınıf' && hasPrefix('course_11_')) {
        await computeForLevel('11. Sınıf', courseIdPrefix: 'course_11_', examKey: '11. Sınıf');
      }
      // TYT / AYT / YDS
      if (hasPrefix('course_tyt_')) {
        await computeForLevel('TYT', courseIdPrefix: 'course_tyt_', examKey: 'TYT');
      }
      if (hasPrefix('course_ayt_')) {
        await computeForLevel('AYT', courseIdPrefix: 'course_ayt_', examKey: 'AYT');
      }
      if (hasPrefix('course_yds_')) {
        await computeForLevel('YDS', courseIdPrefix: 'course_yds_', examKey: 'YDS');
      }
      // Eğer hiçbir sınav bölümü yoksa, sınıf seviyesini genel olarak kullan.
      if (courseOut.isEmpty) {
        await computeForLevel(classLevel);
      }
    } else {
      await computeForLevel(classLevel);
    }

    final overallPercent = overallTotalTopics > 0
        ? ((overallTotalContribution / overallTotalTopics) * 100)
            .round()
            .clamp(0, 100)
        : 0;

    if (!isClosed) {
      emit(
        state.copyWith(
          courseProgressPercent: courseOut,
          overallProgressPercent: overallPercent,
          examSectionProgressPercent: examOut,
          detailedProgressLoaded: true,
        ),
      );
    }
  }
}
