import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

class HomeworksStudentDropdown extends StatelessWidget {
  const HomeworksStudentDropdown({
    super.key,
    required this.students,
    this.selectedStudent,
    required this.onChanged,
  });

  final List<StudentEntity> students;
  final StudentEntity? selectedStudent;
  final void Function(StudentEntity?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Öğrenci Seçin',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        DropdownButtonFormField<StudentEntity?>(
          value: selectedStudent,
          decoration: InputDecoration(
            hintText: 'Bir öğrenci seçin',
            hintStyle: const TextStyle(color: Colors.white54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.secondBackground,
          ),
          dropdownColor: AppColors.background,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          items: [
            const DropdownMenuItem<StudentEntity?>(
              value: null,
              child: Text('Bir öğrenci seçin', style: TextStyle(color: Colors.white54)),
            ),
            ...students.map((s) => DropdownMenuItem<StudentEntity?>(
                  value: s,
                  child: Text(
                    '${s.studentName} ${s.studentSurname}',
                    style: const TextStyle(color: Colors.white),
                  ),
                )),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
