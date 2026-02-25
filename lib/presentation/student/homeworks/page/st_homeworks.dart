import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/presentation/coach/homeworks/widget/homework_week_navigation.dart';
import 'package:polen_academy/presentation/student/homeworks/bloc/st_homeworks_cubit.dart';
import 'package:polen_academy/presentation/student/homeworks/bloc/st_homeworks_state.dart';
import 'package:polen_academy/presentation/student/homeworks/widget/st_homework_daily_card.dart';
import 'package:polen_academy/presentation/student/homeworks/widget/st_homework_detail_sheet.dart';
import 'package:polen_academy/service_locator.dart';

class StHomeworksPage extends StatelessWidget {
  const StHomeworksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = sl<AuthFirebaseService>().getCurrentUserUid() ?? '';
    return BlocProvider(
      create: (_) => StHomeworksCubit(studentId: studentId),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<StHomeworksCubit, StHomeworksState>(
            builder: (context, state) {
              if (state.loading && state.homeworks.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryStudent),
                );
              }
              return RefreshIndicator(
                onRefresh: () => context.read<StHomeworksCubit>().refresh(),
                color: AppColors.primaryStudent,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ödevlerim',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      HomeworkWeekNavigation(
                        weekRangeLabel: state.weekRangeLabel,
                        weekNumber: null,
                        onPrevious: () => context.read<StHomeworksCubit>().previousWeek(),
                        onNext: () => context.read<StHomeworksCubit>().nextWeek(),
                        showAddWeekly: false,
                      ),
                      const SizedBox(height: 20),
                      if (state.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(color: Colors.orange, fontSize: 14),
                          ),
                        ),
                      ...state.weekDays.map((date) {
                        final list = state.homeworksForDay(date);
                        return StHomeworkDailyCard(
                          date: date,
                          homeworks: list,
                          state: state,
                          onHomeworkTap: (h) => _openDetail(context, state, h, studentId),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static void _openDetail(
    BuildContext context,
    StHomeworksState state,
    HomeworkEntity homework,
    String studentId,
  ) {
    final sub = state.submissionFor(homework);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StHomeworkDetailSheet(
        homework: homework,
        studentId: studentId,
        submission: sub,
        onUpdated: () => context.read<StHomeworksCubit>().refresh(),
      ),
    );
  }
}
