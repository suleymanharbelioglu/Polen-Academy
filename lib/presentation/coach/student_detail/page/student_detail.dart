import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/widget/add_parent_dialog.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/common/widget/parent_credentials_dialog.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/auth/entity/parent_credentials_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/usecases/delete_student.dart';
import 'package:polen_academy/domain/user/usecases/update_user_password.dart';
import 'package:polen_academy/presentation/coach/goals/page/goals.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/current_student_cubit.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/parent_signup_cubit.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_cubit.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/class_progress_section.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/general_progress_section.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/homework_status_section.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/profile_section.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/set_password_dialog.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/settings_section.dart';
import 'package:polen_academy/service_locator.dart';

class StudentDetailPage extends StatelessWidget {
  const StudentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentStudentCubit, StudentEntity?>(
      builder: (context, student) {
        if (student == null) {
          return _buildEmptyState(context);
        }
        return BlocProvider(
          create: (_) => StudentDetailCubit()..load(student, student.coachId),
          child: StudentDetailView(student: student),
        );
      },
    );
  }

  static Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondBackground,
        foregroundColor: Colors.white,
        title: const Text('Öğrenci detayı'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Text(
          'Öğrenci bilgisi yok',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}

class StudentDetailView extends StatelessWidget {
  const StudentDetailView({super.key, required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondBackground,
        foregroundColor: Colors.white,
        title: const Text('Öğrenci detayı'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<StudentDetailCubit, StudentDetailState>(
        builder: (context, state) {
          if (_isInitialLoading(state)) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryCoach),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<StudentDetailCubit>().load(
              student,
              student.coachId,
            ),
            color: AppColors.primaryCoach,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileSection(student: student),
                  const SizedBox(height: 20),
                  HomeworkStatusSection(state: state),
                  const SizedBox(height: 20),
                  GeneralProgressSection(state: state),
                  const SizedBox(height: 20),
                  ClassProgressSection(state: state),
                  const SizedBox(height: 20),
                  SettingsSection(
                    student: student,
                    onOpenGoals: () => _openGoals(context),
                    onSetPassword: (userId, label) =>
                        _openSetPassword(context, userId, label),
                    onAddParent: () => _openAddParentDialog(context),
                    onConfirmDelete: () => _confirmDelete(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isInitialLoading(StudentDetailState state) {
    return state.loading &&
        state.overdueCount == 0 &&
        state.completedHomeworkCount == 0 &&
        state.courseProgressPercent.isEmpty;
  }

  void _openGoals(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GoalsPage(initialStudentId: student.uid),
      ),
    );
  }

  Future<void> _openSetPassword(
    BuildContext context,
    String userId,
    String label,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final newPassword = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SetPasswordDialog(
        title: label,
        formKey: formKey,
        controller: controller,
      ),
    );
    if (newPassword == null || newPassword.isEmpty || !context.mounted) return;
    final result = await LoadingOverlay.run(
      context,
      sl<UpdateUserPasswordUseCase>().call(
        params: UpdateUserPasswordParams(
          userId: userId,
          newPassword: newPassword,
        ),
      ),
    );
    if (!context.mounted) return;
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      ),
      (_) => showNewPasswordInfoDialog(context, newPassword),
    );
  }

  Future<void> _openAddParentDialog(BuildContext context) async {
    final credentials = await showDialog<ParentCredentialsEntity>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider(
        create: (_) => ParentSignupCubit(),
        child: AddParentDialog(
          coachId: student.coachId,
          studentId: student.uid,
        ),
      ),
    );
    if (credentials != null && context.mounted) {
      context.read<CurrentStudentCubit>().setStudent(
        student.copyWith(parentId: credentials.parentUid, hasParent: true),
      );
      await ParentCredentialsDialog.show(context, credentials: credentials);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondBackground,
        title: const Text(
          'Öğrenciyi Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          student.hasParent
              ? 'Bu öğrenci ve veli hesabı kalıcı olarak silinecek. Emin misiniz?'
              : 'Bu öğrenci kalıcı olarak silinecek. Emin misiniz?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await LoadingOverlay.run(
      context,
      sl<DeleteStudentUseCase>().call(params: student.uid),
    );
    if (!context.mounted) return;
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      ),
      (_) {
        context.read<CurrentStudentCubit>().clearStudent();
        Navigator.of(context).pop(true);
      },
    );
  }
}
