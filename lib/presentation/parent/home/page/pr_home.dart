import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/parent/bloc/parent_student_cubit.dart';
import 'package:polen_academy/presentation/student/home/bloc/st_home_cubit.dart';
import 'package:polen_academy/presentation/student/home/bloc/st_home_state.dart'
    show StHomeState, StHomeworkItem;
import 'package:polen_academy/presentation/student/home/widget/st_overdue_homework_section.dart';
import 'package:polen_academy/presentation/student/home/widget/st_today_homework_section.dart';
import 'package:polen_academy/presentation/student/home/widget/st_today_session_section.dart';
import 'package:polen_academy/presentation/student/homeworks/widget/st_homework_detail_sheet.dart';

class PrHomePage extends StatelessWidget {
  const PrHomePage({super.key});

  static void _openHomeworkDetail(
    BuildContext context,
    StHomeworkItem item,
    String studentId,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StHomeworkDetailSheet(
        homework: item.homework,
        studentId: studentId,
        submission: item.submission,
        onUpdated: () => context.read<StHomeCubit>().load(),
        showMarkAsDone: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentStudentCubit, StudentEntity?>(
      builder: (context, student) {
        if (student == null) {
          return const Center(
            child: Text(
              'Bağlı öğrenci bulunamadı',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }
        final studentId = student.uid;
        return BlocProvider(
          create: (_) => StHomeCubit(studentId: studentId),
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: BlocBuilder<StHomeCubit, StHomeState>(
                builder: (context, state) {
                  if (state.loading && state.todaySessions.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryParent,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => context.read<StHomeCubit>().load(),
                    color: AppColors.primaryParent,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: StTodaySessionSection(
                              sessions: state.todaySessions,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: StTodayHomeworkSection(
                              items: state.todayHomeworkItems,
                              onTap: (item) =>
                                  _openHomeworkDetail(context, item, studentId),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: StOverdueHomeworkSection(
                              items: state.overdueHomeworkItems,
                              onTap: (item) =>
                                  _openHomeworkDetail(context, item, studentId),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
