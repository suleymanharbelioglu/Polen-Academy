import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/my_all_students/page/my_all_students.dart';

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
                onPressed: () {},
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
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final initial = (student.studentName.isNotEmpty ? student.studentName[0] : '')
        + (student.studentSurname.isNotEmpty ? student.studentSurname[0] : '');
    final name = '${student.studentName} ${student.studentSurname}'.trim();
    return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Öğrenci' : name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('Haftalık Ödev ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text('0/', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('0', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 12),
                    Text('İlerleme: %${student.progress}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
