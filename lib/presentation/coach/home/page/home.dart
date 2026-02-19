import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/presentation/coach/home/bloc/home_cubit.dart';
import 'package:polen_academy/presentation/coach/home/bloc/home_state.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/presentation/coach/home/widget/completed_homeworks_section.dart';
import 'package:polen_academy/presentation/coach/home/widget/homework_detail_sheet.dart';
import 'package:polen_academy/presentation/coach/home/widget/daily_agenda_section.dart';
import 'package:polen_academy/presentation/coach/home/widget/general_status_section.dart';
import 'package:polen_academy/presentation/coach/home/widget/my_students_section.dart';
import 'package:polen_academy/presentation/coach/home/widget/pending_approval_section.dart';
import 'package:polen_academy/service_locator.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final coachId = sl<AuthFirebaseService>().getCurrentUserUid() ?? '';
    return BlocProvider(
      create: (_) => HomeCubit(coachId: coachId),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () => context.read<HomeCubit>().load(),
                color: AppColors.primaryCoach,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GeneralStatusSection(
                        activeStudentCount: state.students.length,
                      ),
                      const SizedBox(height: 16),
                      DailyAgendaSection(
                        sessions: state.todaySessions,
                        coachId: coachId,
                        students: state.students,
                        onApprove: (id, [note]) => context.read<HomeCubit>().approveSession(id, note),
                        onCancel: (id, [note]) => context.read<HomeCubit>().cancelSession(id, note),
                        onSessionPlanned: () => context.read<HomeCubit>().load(),
                      ),
                      const SizedBox(height: 16),
                      StudentsSection(students: state.students),
                      const SizedBox(height: 16),
                      CompletedHomeworkSection(
                        items: state.completedHomeworks,
                        onTap: (item) => _showHomeworkDetail(context, item),
                        onRefresh: () => context.read<HomeCubit>().load(),
                      ),
                      const SizedBox(height: 16),
                      const PendingApprovalSection(),
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

  static void _showHomeworkDetail(BuildContext context, CompletedHomeworkItem item) {
    final cubit = context.read<HomeCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: HomeworkDetailSheet(item: item),
      ),
    );
  }
}
