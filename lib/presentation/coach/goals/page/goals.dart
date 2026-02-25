import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/presentation/coach/goals/bloc/goals_cubit.dart';
import 'package:polen_academy/presentation/coach/goals/bloc/goals_state.dart';
import 'package:polen_academy/presentation/coach/goals/widget/curriculum_tree_section.dart';
import 'package:polen_academy/presentation/coach/goals/widget/goals_course_dropdown.dart';
import 'package:polen_academy/presentation/coach/goals/widget/goals_student_dropdown.dart';
import 'package:polen_academy/service_locator.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key, this.initialStudentId});

  final String? initialStudentId;

  @override
  Widget build(BuildContext context) {
    final coachId = sl<AuthFirebaseService>().getCurrentUserUid() ?? '';
    return BlocProvider(
      create: (_) => GoalsCubit(coachId: coachId, initialStudentId: initialStudentId)..loadStudents(),
      child: const _GoalsView(),
    );
  }
}

class _GoalsView extends StatefulWidget {
  const _GoalsView();

  @override
  State<_GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<_GoalsView> {
  bool _overlayVisible = false;

  void _syncLoadingOverlay(GoalsState state) {
    final showOverlay = state.loading || state.saving;
    if (showOverlay && !_overlayVisible) {
      LoadingOverlay.show(context);
      setState(() => _overlayVisible = true);
    } else if (!showOverlay && _overlayVisible) {
      LoadingOverlay.hide(context);
      setState(() => _overlayVisible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoalsCubit, GoalsState>(
      listener: (context, state) => _syncLoadingOverlay(state),
      child: BlocBuilder<GoalsCubit, GoalsState>(
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
                    onPressed: () => context.read<GoalsCubit>().loadStudents(),
                    child: const Text(
                      'Tekrar dene',
                      style: TextStyle(color: AppColors.primaryCoach),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<GoalsCubit>().refresh(),
            color: AppColors.primaryCoach,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GoalsStudentDropdown(
                    students: state.students,
                    selectedStudent: state.selectedStudent,
                    onChanged: (s) =>
                        context.read<GoalsCubit>().selectStudent(s),
                  ),
                  if (state.selectedStudent != null) ...[
                    const SizedBox(height: 16),
                    _ClassLevelRow(classLevel: state.classLevel ?? ''),
                    const SizedBox(height: 16),
                    if (state.curriculumTree != null &&
                        state.curriculumTree!.courses.isNotEmpty) ...[
                      GoalsCourseDropdown(
                        courses: state.curriculumTree!.courses,
                        selectedCourseId: state.selectedCourseId,
                        onChanged: (id) =>
                            context.read<GoalsCubit>().selectCourse(id),
                      ),
                      const SizedBox(height: 16),
                      CurriculumTreeSection(
                        courses: state.displayedCourses,
                        getKonuStatus: (id) =>
                            context.read<GoalsCubit>().getKonuStatus(id),
                        getRevisionStatus: (id) =>
                            context.read<GoalsCubit>().getRevisionStatus(id),
                        getUnitKonuStatus: (unit) =>
                            context.read<GoalsCubit>().getUnitKonuStatus(unit),
                        getUnitRevisionStatus: (unit) =>
                            context.read<GoalsCubit>().getUnitRevisionStatus(unit),
                        onUpdateTopicProgress: (id, {konuStatus, revisionStatus}) =>
                            context.read<GoalsCubit>().updateTopicProgress(
                                  id,
                                  konuStatus: konuStatus,
                                  revisionStatus: revisionStatus,
                                ),
                        onUpdateUnitProgress: (unit, {konuStatus, revisionStatus}) =>
                            context.read<GoalsCubit>().updateUnitProgress(
                                  unit,
                                  konuStatus: konuStatus,
                                  revisionStatus: revisionStatus,
                                ),
                      ),
                    ] else if (!state.loading &&
                        state.selectedStudent != null) ...[
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Bu sınıf için müfredat yükleniyor veya henüz eklenmemiş.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text(
                          'Öğrenci seçerek konu takibini görüntüleyebilirsiniz.',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClassLevelRow extends StatelessWidget {
  const _ClassLevelRow({required this.classLevel});

  final String classLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            'Sınıf: ',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          Text(
            classLevel.isEmpty ? '—' : classLevel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
