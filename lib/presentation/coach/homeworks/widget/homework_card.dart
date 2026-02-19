import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';

/// Ödev kartı: durum rengine göre sol kenar, başlık/açıklama, tıklanabilir.
class HomeworkCard extends StatelessWidget {
  const HomeworkCard({
    super.key,
    required this.homework,
    required this.displayStatus,
    required this.onTap,
  });

  final HomeworkEntity homework;
  final HomeworkSubmissionStatus displayStatus;
  final VoidCallback onTap;

  static Color colorForStatus(HomeworkSubmissionStatus s) {
    switch (s) {
      case HomeworkSubmissionStatus.approved:
        return Colors.green;
      case HomeworkSubmissionStatus.completedByStudent:
        return Colors.amber; // Onay Bekliyor - sarı
      case HomeworkSubmissionStatus.missing:
        return Colors.orange;
      case HomeworkSubmissionStatus.notDone:
        return Colors.red;
      case HomeworkSubmissionStatus.pending:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForStatus(displayStatus);
    final courseLabel = homework.courseId != null && homework.courseId!.isNotEmpty
        ? homework.courseId!
        : 'Ödev';
    final desc = homework.description.isEmpty ? 'Ödev' : homework.description;
    return Material(
      color: AppColors.secondBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                courseLabel.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
