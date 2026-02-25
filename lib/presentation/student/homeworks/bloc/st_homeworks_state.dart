import 'package:equatable/equatable.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/presentation/student/home/bloc/st_home_state.dart';

class StHomeworksState extends Equatable {
  StHomeworksState({
    this.items = const [],
    DateTime? weekStart,
    DateTime? weekEnd,
    this.homeworks = const [],
    this.submissionByHomeworkId = const {},
    this.loading = false,
    this.errorMessage,
  }) : weekStart = weekStart ?? _defaultWeekStart(),
       weekEnd = weekEnd ?? _defaultWeekEnd();

  final List<StHomeworkItem> items;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<HomeworkEntity> homeworks;
  final Map<String, HomeworkSubmissionEntity> submissionByHomeworkId;
  final bool loading;
  final String? errorMessage;

  static DateTime _defaultWeekStart() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final diff = weekday - DateTime.monday;
    return DateTime(
      now.year,
      now.month,
      now.day - (diff >= 0 ? diff : diff + 7),
    );
  }

  static DateTime _defaultWeekEnd() {
    final start = _defaultWeekStart();
    return start.add(const Duration(days: 6));
  }

  String get weekRangeLabel {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    final s = '${weekStart.day} ${months[weekStart.month - 1]}';
    final e = '${weekEnd.day} ${months[weekEnd.month - 1]}';
    return '$s - $e';
  }

  List<DateTime> get weekDays {
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  List<HomeworkEntity> homeworksForDay(DateTime day) {
    return homeworks.where((h) => h.isVisibleOnDate(day)).toList();
  }

  HomeworkSubmissionEntity? submissionFor(HomeworkEntity h) =>
      submissionByHomeworkId[h.id];

  HomeworkSubmissionStatus displayStatus(
    HomeworkEntity h,
    HomeworkSubmissionEntity? sub,
  ) {
    if (sub != null) return sub.status;
    final end = DateTime(h.endDate.year, h.endDate.month, h.endDate.day);
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    if (end.isBefore(today)) return HomeworkSubmissionStatus.notDone;
    return HomeworkSubmissionStatus.pending;
  }

  StHomeworksState copyWith({
    List<StHomeworkItem>? items,
    DateTime? weekStart,
    DateTime? weekEnd,
    List<HomeworkEntity>? homeworks,
    Map<String, HomeworkSubmissionEntity>? submissionByHomeworkId,
    bool? loading,
    String? errorMessage,
    bool clearHomeworks = false,
  }) {
    return StHomeworksState(
      items: items ?? this.items,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      homeworks: clearHomeworks ? [] : (homeworks ?? this.homeworks),
      submissionByHomeworkId: clearHomeworks
          ? {}
          : (submissionByHomeworkId ?? this.submissionByHomeworkId),
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    items,
    weekStart,
    weekEnd,
    homeworks,
    submissionByHomeworkId,
    loading,
    errorMessage,
  ];
}
