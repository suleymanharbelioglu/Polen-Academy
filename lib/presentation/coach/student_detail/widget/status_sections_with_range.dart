import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_cubit.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/homework_status_section.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/session_status_section.dart';
import 'package:polen_academy/presentation/homework_detail/page/homework_detail_page.dart';
import 'package:polen_academy/presentation/session_detail/page/session_detail_page.dart';

/// Ödev durumları ve seans durumları tek blokta; en üstte süre aralığı butonları (Son Hafta, Son Ay, Tümü).
class StatusSectionsWithRange extends StatelessWidget {
  const StatusSectionsWithRange({
    super.key,
    required this.state,
    required this.student,
  });

  final StudentDetailState state;
  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StudentDetailCubit>();
    final selected = state.rangeFilter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.secondBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text(
                'Süre:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    _RangeChip(
                      label: 'Son Hafta',
                      selected: selected == StudentDetailRangeFilter.lastWeek,
                      onTap: () => cubit.setRangeFilter(StudentDetailRangeFilter.lastWeek),
                    ),
                    const SizedBox(width: 8),
                    _RangeChip(
                      label: 'Son Ay',
                      selected: selected == StudentDetailRangeFilter.lastMonth,
                      onTap: () => cubit.setRangeFilter(StudentDetailRangeFilter.lastMonth),
                    ),
                    const SizedBox(width: 8),
                    _RangeChip(
                      label: 'Tümü',
                      selected: selected == StudentDetailRangeFilter.all,
                      onTap: () => cubit.setRangeFilter(StudentDetailRangeFilter.all),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        HomeworkStatusSection(
          state: state,
          onDetailsTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => HomeworkDetailPage(student: student),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SessionStatusSection(
          state: state,
          onDetailsTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => SessionDetailPage(student: student),
            ),
          ),
        ),
      ],
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected
            ? AppColors.primaryCoach.withOpacity(0.3)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.primaryCoach : Colors.white70,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

