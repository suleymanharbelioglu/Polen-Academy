import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/current_student_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/open_student_detail_cubit.dart';

class StudentCard extends StatelessWidget {
  final StudentEntity student;

  const StudentCard({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final initials =
        '${student.studentName.isNotEmpty ? student.studentName[0] : ''}${student.studentSurname.isNotEmpty ? student.studentSurname[0] : ''}'
            .toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.secondBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.read<CurrentStudentCubit>().setStudent(student);
          context.read<OpenStudentDetailCubit>().requestOpen();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryCoach.withOpacity(0.2),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primaryCoach,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${student.studentName} ${student.studentSurname}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.studentClass,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.background,
                child: Text(
                  '${student.progress}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }
}
