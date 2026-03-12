import 'package:polen_academy/core/utils/homework_ui_helper.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';

class HomeworkDetailState {
  const HomeworkDetailState({
    this.student,
    this.rangeFilter = StudentDetailRangeFilter.all,
    this.homeworks = const [],
    this.submissionByHomeworkId = const {},
    this.loading = true,
    this.error,
  });

  final StudentEntity? student;
  final StudentDetailRangeFilter rangeFilter;
  final List<HomeworkEntity> homeworks;
  final Map<String, HomeworkSubmissionEntity> submissionByHomeworkId;
  final bool loading;
  final String? error;

  List<(HomeworkEntity, HomeworkSubmissionStatus)> get completedItems =>
      HomeworkUiHelper.sortedItems(
        HomeworkUiHelper.filterCompleted(homeworks, submissionByHomeworkId),
        submissionByHomeworkId,
      );

  List<(HomeworkEntity, HomeworkSubmissionStatus)> get overdueItems =>
      HomeworkUiHelper.sortedItems(
        HomeworkUiHelper.filterOverdue(homeworks, submissionByHomeworkId),
        submissionByHomeworkId,
      );

  List<(HomeworkEntity, HomeworkSubmissionStatus)> get missingItems =>
      HomeworkUiHelper.sortedItems(
        HomeworkUiHelper.filterMissing(homeworks, submissionByHomeworkId),
        submissionByHomeworkId,
      );

  List<(HomeworkEntity, HomeworkSubmissionStatus)> get notDoneItems =>
      HomeworkUiHelper.sortedItems(
        HomeworkUiHelper.filterNotDone(homeworks, submissionByHomeworkId),
        submissionByHomeworkId,
      );

  List<(HomeworkEntity, HomeworkSubmissionStatus)> get allItems =>
      HomeworkUiHelper.sortedItems(homeworks, submissionByHomeworkId);

  int get completedCount => HomeworkUiHelper.filterCompleted(homeworks, submissionByHomeworkId).length;
  int get overdueCount => HomeworkUiHelper.filterOverdue(homeworks, submissionByHomeworkId).length;
  int get missingCount => HomeworkUiHelper.filterMissing(homeworks, submissionByHomeworkId).length;
  int get notDoneCount => HomeworkUiHelper.filterNotDone(homeworks, submissionByHomeworkId).length;

  HomeworkDetailState copyWith({
    StudentEntity? student,
    StudentDetailRangeFilter? rangeFilter,
    List<HomeworkEntity>? homeworks,
    Map<String, HomeworkSubmissionEntity>? submissionByHomeworkId,
    bool? loading,
    String? error,
  }) {
    return HomeworkDetailState(
      student: student ?? this.student,
      rangeFilter: rangeFilter ?? this.rangeFilter,
      homeworks: homeworks ?? this.homeworks,
      submissionByHomeworkId: submissionByHomeworkId ?? this.submissionByHomeworkId,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
