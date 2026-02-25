import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.student,
    this.accentColor,
  });

  final StudentEntity student;
  /// Öğrenci profil sayfasında primaryStudent kullanılır; null ise primaryCoach.
  final Color? accentColor;

  String get _initials {
    final a = student.studentName.isNotEmpty ? student.studentName[0] : '';
    final b = student.studentSurname.isNotEmpty ? student.studentSurname[0] : '';
    return '$a$b'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: (accentColor ?? AppColors.primaryCoach).withOpacity(0.4),
            child: Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${student.studentName} ${student.studentSurname}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
