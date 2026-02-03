import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/home/widget/completed_homeworks_section.dart';
import 'package:polen_academy/presentation/coach/home/widget/daily_agenda_section.dart';
import 'package:polen_academy/presentation/coach/home/widget/general_status_seciton.dart';
import 'package:polen_academy/presentation/coach/home/widget/my_students_section.dart';
import 'package:polen_academy/presentation/coach/home/widget/pending_approval_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              GeneralStatusSection(),
              SizedBox(height: 16),
              DailyAgendaSection(),
              SizedBox(height: 16),
              StudentsSection(),
              SizedBox(height: 16),
              CompletedHomeworkSection(),
              SizedBox(height: 16),
              PendingApprovalSection(),
            ],
          ),
        ),
      ),
    );
  }
}
