import 'package:equatable/equatable.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';

class StHomeState extends Equatable {
  const StHomeState({
    this.todaySessions = const [],
    this.todayHomeworkItems = const [],
    this.overdueHomeworkItems = const [],
    this.loading = false,
    this.errorMessage,
  });

  final List<SessionEntity> todaySessions;
  final List<StHomeworkItem> todayHomeworkItems;
  final List<StHomeworkItem> overdueHomeworkItems;
  final bool loading;
  final String? errorMessage;

  StHomeState copyWith({
    List<SessionEntity>? todaySessions,
    List<StHomeworkItem>? todayHomeworkItems,
    List<StHomeworkItem>? overdueHomeworkItems,
    bool? loading,
    String? errorMessage,
  }) {
    return StHomeState(
      todaySessions: todaySessions ?? this.todaySessions,
      todayHomeworkItems: todayHomeworkItems ?? this.todayHomeworkItems,
      overdueHomeworkItems: overdueHomeworkItems ?? this.overdueHomeworkItems,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [todaySessions, todayHomeworkItems, overdueHomeworkItems, loading, errorMessage];
}

class StHomeworkItem extends Equatable {
  const StHomeworkItem({
    required this.homework,
    this.submission,
  });

  final HomeworkEntity homework;
  final HomeworkSubmissionEntity? submission;

  HomeworkSubmissionStatus get displayStatus => submission?.status ?? HomeworkSubmissionStatus.pending;

  @override
  List<Object?> get props => [homework.id, submission?.id];
}
