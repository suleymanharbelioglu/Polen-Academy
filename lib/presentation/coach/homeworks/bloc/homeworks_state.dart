import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

class HomeworksState {
  final List<StudentEntity> students;
  final StudentEntity? selectedStudent;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<HomeworkEntity> homeworks;
  /// homeworkId -> submission (seçili öğrenci için)
  final Map<String, HomeworkSubmissionEntity> submissionByHomeworkId;
  final bool loading;
  final String? errorMessage;

  HomeworksState({
    this.students = const [],
    this.selectedStudent,
    DateTime? weekStart,
    DateTime? weekEnd,
    this.homeworks = const [],
    this.submissionByHomeworkId = const {},
    this.loading = false,
    this.errorMessage,
  })  : weekStart = weekStart ?? _defaultWeekStart(),
        weekEnd = weekEnd ?? _defaultWeekEnd();

  static DateTime _defaultWeekStart() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final diff = weekday - DateTime.monday;
    return DateTime(now.year, now.month, now.day - (diff >= 0 ? diff : diff + 7));
  }

  static DateTime _defaultWeekEnd() {
    final start = _defaultWeekStart();
    return start.add(const Duration(days: 6));
  }

  String get weekRangeLabel {
    const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    final s = '${weekStart.day} ${months[weekStart.month - 1]}';
    final e = '${weekEnd.day} ${months[weekEnd.month - 1]}';
    return '$s - $e';
  }

  /// 1. hafta = öğrencinin kayıt olduğu hafta; 2, 3, ... sonraki haftalar. 0 veya negatif gösterilmez.
  int weekNumberFor(StudentEntity? student) {
    final reg = student?.registeredAt;
    if (reg == null) {
      final start = DateTime(weekStart.year, 1, 1);
      final n = 1 + (weekStart.difference(start).inDays / 7).floor();
      return n < 1 ? 1 : n;
    }
    final regWeekday = reg.weekday;
    final diff = regWeekday - DateTime.monday;
    final registrationWeekStart = DateTime(reg.year, reg.month, reg.day - (diff >= 0 ? diff : diff + 7));
    final weeksSince = (weekStart.difference(registrationWeekStart).inDays / 7).floor();
    // Kayıt haftası = 1. hafta; önceki haftalarda da 1 göster (0, -1 yok).
    return weeksSince < 0 ? 1 : (1 + weeksSince);
  }

  /// Eski getter: seçili öğrenci yoksa yıl haftası kullanılır (geri uyumluluk).
  int get weekNumber => weekNumberFor(selectedStudent);

  List<DateTime> get weekDays {
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  List<HomeworkEntity> homeworksForDay(DateTime day) {
    return homeworks.where((h) => h.isVisibleOnDate(day)).toList();
  }

  HomeworkSubmissionEntity? submissionFor(HomeworkEntity h) =>
      submissionByHomeworkId[h.id];

  /// Gösterim için durum: öğrenci yükleme yapmamış ve bitiş geçmişse notDone.
  HomeworkSubmissionStatus displayStatus(HomeworkEntity h, HomeworkSubmissionEntity? sub) {
    if (sub != null) return sub.status;
    final end = DateTime(h.endDate.year, h.endDate.month, h.endDate.day);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (end.isBefore(today)) return HomeworkSubmissionStatus.notDone;
    return HomeworkSubmissionStatus.pending;
  }

  HomeworksState copyWith({
    List<StudentEntity>? students,
    StudentEntity? selectedStudent,
    DateTime? weekStart,
    DateTime? weekEnd,
    List<HomeworkEntity>? homeworks,
    Map<String, HomeworkSubmissionEntity>? submissionByHomeworkId,
    bool? loading,
    String? errorMessage,
    bool clearStudent = false,
    bool clearHomeworks = false,
  }) {
    return HomeworksState(
      students: students ?? this.students,
      selectedStudent: clearStudent ? null : (selectedStudent ?? this.selectedStudent),
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      homeworks: clearHomeworks ? [] : (homeworks ?? this.homeworks),
      submissionByHomeworkId: clearHomeworks ? {} : (submissionByHomeworkId ?? this.submissionByHomeworkId),
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}
