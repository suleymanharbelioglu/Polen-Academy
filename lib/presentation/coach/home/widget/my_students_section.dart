import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/widget/add_student_dialog.dart';
import 'package:polen_academy/common/widget/student_credentials_dialog.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/auth/entity/student_credentials_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/home/bloc/home_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/current_student_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/student_creation_req_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/page/my_all_students.dart';
import 'package:polen_academy/presentation/coach/student_detail/page/student_detail.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/general_progress_section.dart';

class StudentsSection extends StatelessWidget {
  const StudentsSection({
    super.key,
    this.students = const [],
  });

  final List<StudentEntity> students;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Öğrencilerim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showAddStudentDialog(context),
                child: const Text(
                  '+ Ekle',
                  style: TextStyle(color: AppColors.primaryCoach),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyAllStudentsPage(),
                    ),
                  );
                },
                child: const Text(
                  'Tümünü Gör',
                  style: TextStyle(color: AppColors.primaryCoach),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (students.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Henüz öğrenci yok.',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            )
          else
            ...students.take(5).map((s) => _StudentCard(student: s)),
          if (students.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyAllStudentsPage(),
                      ),
                    );
                  },
                  child: Text('+ ${students.length - 5} daha', style: const TextStyle(color: AppColors.primaryCoach)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Future<void> _showAddStudentDialog(BuildContext context) async {
    final credentials = await showDialog<StudentCredentialsEntity>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider(
        create: (_) => StudentCreationReqCubit(),
        child: const AddStudentDialog(),
      ),
    );
    if (credentials != null && context.mounted) {
      context.read<HomeCubit>().load();
      await StudentCredentialsDialog.show(context, credentials: credentials);
    }
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final initial = (student.studentName.isNotEmpty ? student.studentName[0] : '')
        + (student.studentSurname.isNotEmpty ? student.studentSurname[0] : '');
    final name = '${student.studentName} ${student.studentSurname}'.trim();
    return InkWell(
      onTap: () => _openStudentDetail(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryCoach.withValues(alpha: 0.3),
              child: Text(
                initial.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name.isEmpty ? 'Öğrenci' : name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            GeneralProgressCircle(
              percent: student.progress,
              diameter: 44,
              strokeWidth: 4,
              showPercent: false,
            ),
          ],
        ),
      ),
    );
  }

  void _openStudentDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) {
            final cubit = CurrentStudentCubit();
            cubit.setStudent(student);
            return cubit;
          },
          child: const StudentDetailPage(),
        ),
      ),
    );
  }
}
