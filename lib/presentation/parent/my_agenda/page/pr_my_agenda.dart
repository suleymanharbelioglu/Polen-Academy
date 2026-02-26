import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/parent/bloc/parent_student_cubit.dart';
import 'package:polen_academy/presentation/student/my_agenda/page/st_my_agenda.dart';

class PrMyAgendaPage extends StatelessWidget {
  const PrMyAgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentStudentCubit, StudentEntity?>(
      builder: (context, student) {
        if (student == null) {
          return const Center(
            child: Text(
              'Bağlı öğrenci bulunamadı',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }
        return StMyAgendaPage(
          overrideStudentId: student.uid,
          primaryColor: AppColors.primaryParent,
        );
      },
    );
  }
}
