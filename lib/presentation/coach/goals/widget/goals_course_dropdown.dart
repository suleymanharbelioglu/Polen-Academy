import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';

class GoalsCourseDropdown extends StatelessWidget {
  const GoalsCourseDropdown({
    super.key,
    required this.courses,
    this.selectedCourseId,
    required this.onChanged,
  });

  final List<CourseWithUnits> courses;
  final String? selectedCourseId;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      value: selectedCourseId,
      decoration: InputDecoration(
        labelText: 'Ders Seçin',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.secondBackground,
      ),
      dropdownColor: AppColors.background,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Hepsini Gör', style: TextStyle(color: Colors.white)),
        ),
        ...courses.map((c) => DropdownMenuItem<String?>(
              value: c.course.id,
              child: Text(c.course.name, style: const TextStyle(color: Colors.white)),
            )),
      ],
      onChanged: onChanged,
    );
  }
}
