import 'package:polen_academy/domain/user/entity/student_entity.dart';

/// Öğrenci detay sayfası: ödev durumları, genel ilerleme, sınıf ilerleme %.
class StudentDetailState {
  final StudentEntity? student;
  /// 7, 14 veya 30 gün
  final int periodDays;
  final int overdueCount;
  final int missingCount;
  final int notDoneCount;
  final int completedHomeworkCount;
  final int attendedSessionCount;
  final int solvedQuestionCount;
  final int trialCount;
  final int meetingCount;
  /// Sınıfa göre ders adı -> yüzde (0-100). Örn: {"Matematik": 10, "Fen Bilimleri": 0}
  final Map<String, int> courseProgressPercent;
  final bool loading;
  final String? errorMessage;

  const StudentDetailState({
    this.student,
    this.periodDays = 7,
    this.overdueCount = 0,
    this.missingCount = 0,
    this.notDoneCount = 0,
    this.completedHomeworkCount = 0,
    this.attendedSessionCount = 0,
    this.solvedQuestionCount = 0,
    this.trialCount = 0,
    this.meetingCount = 0,
    this.courseProgressPercent = const {},
    this.loading = false,
    this.errorMessage,
  });

  StudentDetailState copyWith({
    StudentEntity? student,
    int? periodDays,
    int? overdueCount,
    int? missingCount,
    int? notDoneCount,
    int? completedHomeworkCount,
    int? attendedSessionCount,
    int? solvedQuestionCount,
    int? trialCount,
    int? meetingCount,
    Map<String, int>? courseProgressPercent,
    bool? loading,
    String? errorMessage,
  }) {
    return StudentDetailState(
      student: student ?? this.student,
      periodDays: periodDays ?? this.periodDays,
      overdueCount: overdueCount ?? this.overdueCount,
      missingCount: missingCount ?? this.missingCount,
      notDoneCount: notDoneCount ?? this.notDoneCount,
      completedHomeworkCount: completedHomeworkCount ?? this.completedHomeworkCount,
      attendedSessionCount: attendedSessionCount ?? this.attendedSessionCount,
      solvedQuestionCount: solvedQuestionCount ?? this.solvedQuestionCount,
      trialCount: trialCount ?? this.trialCount,
      meetingCount: meetingCount ?? this.meetingCount,
      courseProgressPercent: courseProgressPercent ?? this.courseProgressPercent,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}
