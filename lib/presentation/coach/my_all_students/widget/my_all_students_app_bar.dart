import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/request_add_student_cubit.dart';

class MyAllStudentsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAllStudentsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.secondBackground,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Öğrencilerim',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton.icon(
            onPressed: () => context.read<RequestAddStudentCubit>().requestOpen(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCoach,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
