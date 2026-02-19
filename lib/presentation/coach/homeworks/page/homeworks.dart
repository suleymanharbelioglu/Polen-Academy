import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/domain/homework/usecases/set_homework_submission_status.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/home/widget/homework_detail_sheet.dart';
import 'package:polen_academy/presentation/coach/homeworks/bloc/homeworks_cubit.dart';
import 'package:polen_academy/presentation/coach/homeworks/bloc/homeworks_state.dart';
import 'package:polen_academy/presentation/coach/homeworks/widget/homework_daily_card.dart';
import 'package:polen_academy/presentation/coach/homeworks/widget/homework_week_navigation.dart';
import 'package:polen_academy/presentation/coach/homeworks/widget/homeworks_student_dropdown.dart';
import 'package:polen_academy/presentation/coach/homeworks/page/add_homework_page.dart';
import 'package:polen_academy/service_locator.dart';

class HomeworksPage extends StatelessWidget {
  const HomeworksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final coachId = sl<AuthFirebaseService>().getCurrentUserUid() ?? '';
    return BlocProvider(
      create: (_) => HomeworksCubit(coachId: coachId)..loadStudents(),
      child: const _HomeworksView(),
    );
  }
}

class _HomeworksView extends StatefulWidget {
  const _HomeworksView();

  @override
  State<_HomeworksView> createState() => _HomeworksViewState();
}

class _HomeworksViewState extends State<_HomeworksView> {
  bool _overlayVisible = false;

  void _syncLoadingOverlay(HomeworksState state) {
    if (state.loading && !_overlayVisible) {
      LoadingOverlay.show(context);
      setState(() => _overlayVisible = true);
    } else if (!state.loading && _overlayVisible) {
      LoadingOverlay.hide(context);
      setState(() => _overlayVisible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeworksCubit, HomeworksState>(
      listener: (context, state) => _syncLoadingOverlay(state),
      child: BlocBuilder<HomeworksCubit, HomeworksState>(
        builder: (context, state) {
          if (state.loading && state.students.isEmpty) {
            return const SizedBox.shrink();
          }
          if (state.errorMessage != null && state.students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.read<HomeworksCubit>().loadStudents(),
                    child: const Text('Tekrar dene', style: TextStyle(color: AppColors.primaryCoach)),
                  ),
                ],
              ),
            );
          }

          if (state.selectedStudent == null) {
            return RefreshIndicator(
              onRefresh: () => context.read<HomeworksCubit>().loadStudents(),
              color: AppColors.primaryCoach,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeworksStudentDropdown(
                      students: state.students,
                      selectedStudent: state.selectedStudent,
                      onChanged: (s) => context.read<HomeworksCubit>().selectStudent(s),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.secondBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Lütfen ödevlerini görüntülemek için bir öğrenci seçin.',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<HomeworksCubit>().refresh(),
            color: AppColors.primaryCoach,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeworksStudentDropdown(
                    students: state.students,
                    selectedStudent: state.selectedStudent,
                    onChanged: (s) => context.read<HomeworksCubit>().selectStudent(s),
                  ),
                  const SizedBox(height: 20),
                  HomeworkWeekNavigation(
                    weekRangeLabel: state.weekRangeLabel,
                    weekNumber: state.weekNumber,
                    onPrevious: () => context.read<HomeworksCubit>().previousWeek(),
                    onNext: () => context.read<HomeworksCubit>().nextWeek(),
                    showAddWeekly: false,
                  ),
                  const SizedBox(height: 20),
                  _buildDailyContent(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static bool _isPast(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return d.isBefore(today);
  }

  Widget _buildDailyContent(BuildContext context, HomeworksState state) {
    return Column(
      children: state.weekDays.map((date) {
        final list = state.homeworksForDay(date);
        final canAdd = !_isPast(date);
        return HomeworkDailyCard(
          date: date,
          homeworks: list,
          state: state,
          canAddHomework: canAdd,
          onAdd: () => _openAddHomework(context, state.selectedStudent!, date: date),
          onHomeworkTap: (h) => _openHomeworkDetail(context, state, h),
        );
      }).toList(),
    );
  }

  void _openHomeworkDetail(BuildContext context, HomeworksState state, HomeworkEntity homework) {
    final student = state.selectedStudent!;
    final studentName = '${student.studentName} ${student.studentSurname}';
    final sub = state.submissionByHomeworkId[homework.id];
    final submission = sub ??
        HomeworkSubmissionEntity(
          id: '',
          homeworkId: homework.id,
          studentId: student.uid,
          status: HomeworkSubmissionStatus.pending,
          uploadedUrls: const [],
          completedAt: null,
          updatedAt: DateTime.now(),
        );
    final item = CompletedHomeworkItem(
      homework: homework,
      submission: submission,
      studentName: studentName,
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HomeworkDetailSheet(
        item: item,
        onStatusChanged: (homeworkId, studentId, status) =>
            _setStatusFromHomeworks(ctx, homeworkId, studentId, status),
      ),
    );
  }

  Future<void> _setStatusFromHomeworks(
    BuildContext context,
    String homeworkId,
    String studentId,
    HomeworkSubmissionStatus status,
  ) async {
    final result = await sl<SetHomeworkSubmissionStatusUseCase>().call(
      params: SetHomeworkSubmissionStatusParams(
        homeworkId: homeworkId,
        studentId: studentId,
        status: status,
      ),
    );
    if (context.mounted) {
      result.fold(
        (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e))),
        (_) => context.read<HomeworksCubit>().refresh(),
      );
    }
  }

  void _openAddHomework(BuildContext context, StudentEntity student, {DateTime? date}) {
    if (date != null && _isPast(date)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçmiş günlere ödev eklenemez.'), backgroundColor: Colors.orange),
      );
      return;
    }
    final cubit = context.read<HomeworksCubit>();
    final weekStart = cubit.state.weekStart;
    final coachId = cubit.coachId;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddHomeworkPage(
          student: student,
          initialDate: date ?? weekStart,
          coachId: coachId,
        ),
      ),
    ).then((_) => cubit.refresh());
  }
}
