import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/presentation/coach/homeworks/bloc/homeworks_state.dart';
import 'package:polen_academy/presentation/coach/homeworks/widget/homework_card.dart';

class HomeworkDailyCard extends StatelessWidget {
  const HomeworkDailyCard({
    super.key,
    required this.date,
    required this.homeworks,
    required this.state,
    required this.canAddHomework,
    required this.onAdd,
    required this.onHomeworkTap,
  });

  final DateTime date;
  final List<HomeworkEntity> homeworks;
  final HomeworksState state;
  final bool canAddHomework;
  final VoidCallback onAdd;
  final void Function(HomeworkEntity homework) onHomeworkTap;

  static const _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    final dayName = _dayNames[date.weekday - 1];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        color: date.day == DateTime.now().day &&
                                date.month == DateTime.now().month
                            ? AppColors.primaryCoach
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      homeworks.isEmpty
                          ? 'Ödev yok'
                          : '${homeworks.length} ödev',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (canAddHomework)
                Material(
                  color: AppColors.primaryCoach,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onAdd,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (homeworks.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...homeworks.map((h) {
              final sub = state.submissionFor(h);
              final displayStatus = state.displayStatus(h, sub);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: HomeworkCard(
                    homework: h,
                    displayStatus: displayStatus,
                    onTap: () => onHomeworkTap(h),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
