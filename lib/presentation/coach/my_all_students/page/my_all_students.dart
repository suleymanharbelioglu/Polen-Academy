import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/bloc/is_premium_cubit.dart';
import 'package:polen_academy/common/widget/add_student_dialog.dart';
import 'package:polen_academy/common/widget/student_credentials_dialog.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/core/network/network_error_helper.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/auth/entity/student_credentials_entity.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/current_student_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/display_my_all_students_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/display_my_all_students_state.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/open_student_detail_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/open_student_detail_state.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/request_add_student_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/request_add_student_state.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/student_creation_req_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/widget/my_all_students_app_bar.dart';
import 'package:polen_academy/presentation/coach/my_all_students/widget/student_card.dart';
import 'package:polen_academy/presentation/coach/student_detail/page/student_detail.dart';
import 'package:polen_academy/presentation/coach/vip/page/vip_page.dart';
import 'package:polen_academy/service_locator.dart';

class MyAllStudentsPage extends StatelessWidget {
  const MyAllStudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RequestAddStudentCubit()),
        BlocProvider(create: (_) => OpenStudentDetailCubit()),
        BlocProvider(create: (_) => StudentCreationReqCubit()),
        BlocProvider(
          create: (_) {
            final cubit = DisplayMyAllStudentsCubit();
            final coachUid = sl<AuthFirebaseService>().getCurrentUserUid();
            if (coachUid != null) cubit.getMyStudents(coachUid);
            return cubit;
          },
        ),
        BlocProvider(create: (_) => CurrentStudentCubit()),
      ],
      child: _MyAllStudentsView(),
    );
  }
}

class _MyAllStudentsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OpenStudentDetailCubit, OpenStudentDetailState>(
          listenWhen: (_, state) => state is OpenStudentDetailRequested,
          listener: (context, state) {
            context.read<OpenStudentDetailCubit>().reset();
            final coachUid = sl<AuthFirebaseService>().getCurrentUserUid();
            Navigator.of(context).push<bool>(
              MaterialPageRoute<bool>(
                builder: (_) => BlocProvider.value(
                  value: context.read<CurrentStudentCubit>(),
                  child: const StudentDetailPage(),
                ),
              ),
            ).then((deleted) {
              if (deleted == true && context.mounted && coachUid != null) {
                context.read<CurrentStudentCubit>().clearStudent();
                context.read<DisplayMyAllStudentsCubit>().getMyStudents(coachUid);
              }
            });
          },
        ),
        BlocListener<RequestAddStudentCubit, RequestAddStudentState>(
          listenWhen: (_, state) => state is RequestAddStudentOpenDialog,
          listener: (context, state) {
            context.read<RequestAddStudentCubit>().reset();
            _onRequestAddStudent(context);
          },
        ),
        BlocListener<DisplayMyAllStudentsCubit, DisplayMyAllStudentsState>(
          listenWhen: (_, state) => state is DisplayMyAllStudentsFailure,
          listener: (context, state) {
            if (state is DisplayMyAllStudentsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(NetworkErrorHelper.getUserFriendlyMessage(state.errorMessage)), backgroundColor: Colors.red),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const MyAllStudentsAppBar(),
        body: BlocBuilder<DisplayMyAllStudentsCubit, DisplayMyAllStudentsState>(
          builder: (context, state) {
            if (state is DisplayMyAllStudentsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (state is DisplayMyAllStudentsSuccess) {
              if (state.students.isEmpty) {
                return const Center(
                  child: Text(
                    'Henüz öğrenci eklenmedi',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.students.length,
                itemBuilder: (context, index) {
                  return StudentCard(student: state.students[index]);
                },
              );
            }
            return const Center(
              child: Text(
                'Öğrenciler yüklenemedi',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onRequestAddStudent(BuildContext context) async {
    final coachUid = sl<AuthFirebaseService>().getCurrentUserUid();
    if (coachUid == null) return;
    final isPremium = context.read<IsPremiumCubit>().state;
    final displayState = context.read<DisplayMyAllStudentsCubit>().state;
    final studentCount = displayState is DisplayMyAllStudentsSuccess ? displayState.students.length : 0;
    if (!isPremium && studentCount >= 1) {
      final shouldOpenVip = await _showPremiumRequiredDialog(context);
      if (!context.mounted) return;
      if (shouldOpenVip) {
        final activated = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const VipPage()),
        );
        if (activated == true && context.mounted) {
          context.read<IsPremiumCubit>().activatePremium();
        }
      }
      return;
    }
    _showAddStudentDialog(context);
  }

  Future<bool> _showPremiumRequiredDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Premium Gerekli'),
        content: const Text(
          'Premium üyeliğiniz olmadığı için en fazla 1 öğrenci ekleyebilirsiniz. Daha fazla öğrenci eklemek için Premium sayfasına gidin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryCoach),
            child: const Text('Premiuma Git'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showAddStudentDialog(BuildContext context) async {
    final credentials = await showDialog<StudentCredentialsEntity>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider(
        create: (_) => StudentCreationReqCubit(),
        child: const AddStudentDialog(),
      ),
    );
    if (credentials != null && context.mounted) {
      final coachUid = sl<AuthFirebaseService>().getCurrentUserUid();
      if (coachUid != null) context.read<DisplayMyAllStudentsCubit>().getMyStudents(coachUid);
      StudentCredentialsDialog.show(context, credentials: credentials);
    }
  }
}
