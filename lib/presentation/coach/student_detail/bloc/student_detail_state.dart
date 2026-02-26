import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

/// Ödev ve seans durumları için süre aralığı.
enum StudentDetailRangeFilter {
  lastWeek,
  lastMonth,
  all,
}

/// Öğrenci detay sayfası: ödev durumları, seans durumları, genel ilerleme, sınıf ilerleme %.
class StudentDetailState {
  final StudentEntity? student;
  /// Ödev/seans listeleri için seçili aralık.
  final StudentDetailRangeFilter rangeFilter;
  final int overdueCount;
  final int missingCount;
  final int notDoneCount;
  final int completedHomeworkCount;
  final int attendedSessionCount;
  /// Bu öğrenciyle yapılan (tamamlandı işaretli) seanslar
  final List<SessionEntity> completedSessions;
  /// Bu öğrenciyle yapılmayan (gerçekleşmedi işaretli) seanslar
  final List<SessionEntity> notDoneSessions;
  /// Bu öğrenciyle planlanmış, tarihi henüz gelmemiş seanslar
  final List<SessionEntity> futureSessions;
  final int solvedQuestionCount;
  final int trialCount;
  final int meetingCount;
  /// Sınıfa göre ders adı -> yüzde (0-100). Örn: {"Matematik": 10, "Fen Bilimleri": 0}
  final Map<String, int> courseProgressPercent;
  /// Genel ilerleme: tamamlanan konu sayısı / toplam konu sayısı (0-100).
  final int overallProgressPercent;
  final bool loading;
  final String? errorMessage;

  const StudentDetailState({
    this.student,
    this.rangeFilter = StudentDetailRangeFilter.lastWeek,
    this.overdueCount = 0,
    this.missingCount = 0,
    this.notDoneCount = 0,
    this.completedHomeworkCount = 0,
    this.attendedSessionCount = 0,
    this.completedSessions = const [],
    this.notDoneSessions = const [],
    this.futureSessions = const [],
    this.solvedQuestionCount = 0,
    this.trialCount = 0,
    this.meetingCount = 0,
    this.courseProgressPercent = const {},
    this.overallProgressPercent = 0,
    this.loading = false,
    this.errorMessage,
  });

  StudentDetailState copyWith({
    StudentEntity? student,
    StudentDetailRangeFilter? rangeFilter,
    int? overdueCount,
    int? missingCount,
    int? notDoneCount,
    int? completedHomeworkCount,
    int? attendedSessionCount,
    List<SessionEntity>? completedSessions,
    List<SessionEntity>? notDoneSessions,
    List<SessionEntity>? futureSessions,
    int? solvedQuestionCount,
    int? trialCount,
    int? meetingCount,
    Map<String, int>? courseProgressPercent,
    int? overallProgressPercent,
    bool? loading,
    String? errorMessage,
  }) {
    return StudentDetailState(
      student: student ?? this.student,
      rangeFilter: rangeFilter ?? this.rangeFilter,
      overdueCount: overdueCount ?? this.overdueCount,
      missingCount: missingCount ?? this.missingCount,
      notDoneCount: notDoneCount ?? this.notDoneCount,
      completedHomeworkCount: completedHomeworkCount ?? this.completedHomeworkCount,
      attendedSessionCount: attendedSessionCount ?? this.attendedSessionCount,
      completedSessions: completedSessions ?? this.completedSessions,
      notDoneSessions: notDoneSessions ?? this.notDoneSessions,
      futureSessions: futureSessions ?? this.futureSessions,
      solvedQuestionCount: solvedQuestionCount ?? this.solvedQuestionCount,
      trialCount: trialCount ?? this.trialCount,
      meetingCount: meetingCount ?? this.meetingCount,
      courseProgressPercent: courseProgressPercent ?? this.courseProgressPercent,
      overallProgressPercent: overallProgressPercent ?? this.overallProgressPercent,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}
