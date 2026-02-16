import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/goals/bloc/goals_cubit.dart';
import 'package:polen_academy/presentation/coach/goals/bloc/goals_state.dart';
import 'package:polen_academy/presentation/coach/goals/widget/curriculum_tree_section.dart';
import 'package:polen_academy/presentation/coach/goals/widget/goals_course_dropdown.dart';
import 'package:polen_academy/presentation/coach/goals/widget/goals_student_dropdown.dart';
import 'package:polen_academy/service_locator.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final coachId = sl<AuthFirebaseService>().getCurrentUserUid() ?? '';
    return BlocProvider(
      create: (_) => GoalsCubit(coachId: coachId)..loadStudents(),
      child: const _GoalsView(),
    );
  }
}

class _GoalsView extends StatelessWidget {
  const _GoalsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalsCubit, GoalsState>(
      builder: (context, state) {
        if (state.loading && state.students.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
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
                  child: const Text('Tekrar dene', style: TextStyle(color: AppColors.primaryCoach)),
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
                  onChanged: (s) => context.read<GoalsCubit>().selectStudent(s),
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
                      onChanged: (id) => context.read<GoalsCubit>().selectCourse(id),
                    ),
                    const SizedBox(height: 16),
                    if (state.loading && state.curriculumTree != null)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primaryCoach),
                        ),
                      )
                    else
                      CurriculumTreeSection(
                        courses: state.displayedCourses,
                        isKonuStudied: (id) => context.read<GoalsCubit>().isKonuStudied(id),
                        isRevisionDone: (id) => context.read<GoalsCubit>().isRevisionDone(id),
                        onUpdateKonu: (id, v) => context
                            .read<GoalsCubit>()
                            .updateTopicProgress(id, konuStudied: v),
                        onUpdateRevision: (id, v) => context
                            .read<GoalsCubit>()
                            .updateTopicProgress(id, revisionDone: v),
                      ),
                  ] else if (!state.loading && state.selectedStudent != null) ...[
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Bu sınıf için müfredat yükleniyor veya henüz eklenmemiş.',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
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
