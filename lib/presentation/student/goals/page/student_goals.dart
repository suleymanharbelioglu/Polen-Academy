import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/goals/entity/topic_status.dart';
import 'package:polen_academy/presentation/coach/goals/bloc/goals_state.dart';
import 'package:polen_academy/presentation/coach/goals/widget/curriculum_tree_section.dart';
import 'package:polen_academy/presentation/coach/goals/widget/goals_course_dropdown.dart';
import 'package:polen_academy/presentation/student/goals/bloc/student_goals_cubit.dart';
import 'package:polen_academy/service_locator.dart';

class StudentGoalsPage extends StatelessWidget {
  const StudentGoalsPage({
    super.key,
    this.overrideStudentId,
    this.primaryColor,
  });

  /// Veli sayfasından kullanıldığında bağlı öğrenci uid.
  final String? overrideStudentId;
  /// Veli için AppColors.primaryParent vb.
  final Color? primaryColor;

  @override
  Widget build(BuildContext context) {
    final studentId =
        overrideStudentId ?? sl<AuthFirebaseService>().getCurrentUserUid() ?? '';
    return BlocProvider(
      create: (_) => StudentGoalsCubit(studentId: studentId),
      child: _StudentGoalsView(primaryColor: primaryColor ?? AppColors.primaryStudent),
    );
  }
}

class _StudentGoalsView extends StatelessWidget {
  const _StudentGoalsView({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentGoalsCubit, GoalsState>(
      builder: (context, state) {
        if (state.loading && state.selectedStudent == null) {
          return Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }
        if (state.loading &&
            state.selectedStudent != null &&
            state.curriculumTree == null) {
          return Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }
        if (state.errorMessage != null && !state.loading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.read<StudentGoalsCubit>().load(),
                    child: Text(
                      'Tekrar dene',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<StudentGoalsCubit>().refresh(),
          color: primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.selectedStudent != null) ...[
                  _ClassLevelRow(classLevel: state.classLevel ?? ''),
                  const SizedBox(height: 16),
                  if (state.curriculumTree != null &&
                      state.curriculumTree!.courses.isNotEmpty) ...[
                    GoalsCourseDropdown(
                      courses: state.curriculumTree!.courses,
                      selectedCourseId: state.selectedCourseId,
                      onChanged: (id) =>
                          context.read<StudentGoalsCubit>().selectCourse(id),
                    ),
                    const SizedBox(height: 16),
                    CurriculumTreeSection(
                      courses: state.displayedCourses,
                      getKonuStatus: (id) =>
                          context.read<StudentGoalsCubit>().getKonuStatus(id),
                      getRevisionStatus: (id) =>
                          context.read<StudentGoalsCubit>().getRevisionStatus(id),
                      getUnitKonuStatus: (unit) =>
                          context.read<StudentGoalsCubit>().getUnitKonuStatus(unit),
                      getUnitRevisionStatus: (unit) =>
                          context.read<StudentGoalsCubit>().getUnitRevisionStatus(unit),
                      onUpdateTopicProgress: (String _, {TopicStatus? konuStatus, TopicStatus? revisionStatus}) {},
                      onUpdateUnitProgress: (UnitWithTopics _, {TopicStatus? konuStatus, TopicStatus? revisionStatus}) {},
                      readOnly: true,
                    ),
                  ] else if (!state.loading && state.selectedStudent != null) ...[
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
                        'Hedefleriniz yükleniyor...',
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
