import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/my_all_students/page/my_all_students.dart';

class StudentsSection extends StatelessWidget {
  const StudentsSection({super.key});

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
          const SizedBox(height: 80), // içerik alanı (boş)
        ],
      ),
    );
  }
}
