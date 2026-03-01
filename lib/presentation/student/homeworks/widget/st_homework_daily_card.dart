import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/presentation/coach/homeworks/widget/homework_card.dart';
import 'package:polen_academy/presentation/student/homeworks/bloc/st_homeworks_state.dart';

/// Öğrenci için günlük ödev kartı; koç tasarımıyla aynı, sadece “ödev ekle” butonu yok.
class StHomeworkDailyCard extends StatelessWidget {
  const StHomeworkDailyCard({
    super.key,
    required this.date,
    required this.homeworks,
    required this.state,
    required this.onHomeworkTap,
  });

  final DateTime date;
  final List<HomeworkEntity> homeworks;
  final StHomeworksState state;
  final void Function(HomeworkEntity homework) onHomeworkTap;

  static const _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  /// Sıralama: Tamamlanmış → Onay bekliyor → Bekleyen → Eksik → Yapılmadı
  static int _statusOrder(HomeworkSubmissionStatus s) {
    switch (s) {
      case HomeworkSubmissionStatus.approved:
        return 0;
      case HomeworkSubmissionStatus.completedByStudent:
        return 1;
      case HomeworkSubmissionStatus.pending:
        return 2;
      case HomeworkSubmissionStatus.missing:
        return 3;
      case HomeworkSubmissionStatus.notDone:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayName = _dayNames[date.weekday - 1];
    final isToday = date.day == DateTime.now().day && date.month == DateTime.now().month;
    final sortedHomeworks = List<HomeworkEntity>.from(homeworks)
      ..sort((a, b) {
        final statusA = state.displayStatus(a, state.submissionFor(a));
        final statusB = state.displayStatus(b, state.submissionFor(b));
        return _statusOrder(statusA).compareTo(_statusOrder(statusB));
      });
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
                        color: isToday ? AppColors.primaryStudent : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      homeworks.isEmpty ? 'Ödev yok' : '${homeworks.length} ödev',
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (sortedHomeworks.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...sortedHomeworks.map((h) {
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
