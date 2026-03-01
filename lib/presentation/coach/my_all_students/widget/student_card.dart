import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/current_student_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/open_student_detail_cubit.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/general_progress_section.dart';

class StudentCard extends StatelessWidget {
  final StudentEntity student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final initial =
        (student.studentName.isNotEmpty ? student.studentName[0] : '') +
        (student.studentSurname.isNotEmpty ? student.studentSurname[0] : '');
    final name = '${student.studentName} ${student.studentSurname}'.trim();

    return InkWell(
      onTap: () {
        context.read<CurrentStudentCubit>().setStudent(student);
        context.read<OpenStudentDetailCubit>().requestOpen();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryCoach.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primaryCoach.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                child: Text(
                  initial.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primaryCoach,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name.isEmpty ? 'Öğrenci' : name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  if (student.studentClass.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      student.studentClass,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GeneralProgressCircle(
              percent: student.progress,
              diameter: 58,
              strokeWidth: 5,
              showPercent: true,
              accentColor: AppColors.primaryCoach,
              backgroundColor: Colors.white,
              percentFontSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
