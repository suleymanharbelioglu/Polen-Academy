import 'package:flutter/material.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';

/// Ödev detay sayfasında listelenen ödev kartı. Koç tarafındaki ödev kartı (HomeworkCard) ile aynı mantık: durum rengi, ders, konu, hoca notu.
class HomeworkDetailCard extends StatelessWidget {
  const HomeworkDetailCard({
    super.key,
    required this.homework,
    required this.displayStatus,
  });

  final HomeworkEntity homework;
  final HomeworkSubmissionStatus displayStatus;

  static Color colorForStatus(HomeworkSubmissionStatus s) {
    switch (s) {
      case HomeworkSubmissionStatus.approved:
        return Colors.green;
      case HomeworkSubmissionStatus.completedByStudent:
        return Colors.blue;
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
    final courseLabel = homework.courseName != null &&
            homework.courseName!.isNotEmpty
        ? homework.courseName!
        : (homework.courseId != null && homework.courseId!.isNotEmpty
            ? homework.courseId!
            : 'Ödev');
    final topicText = homework.topicNames.isNotEmpty
        ? homework.topicNames.join(' • ')
        : null;
    final teacherNote =
        homework.description.isEmpty ? 'Ödev' : homework.description;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseLabel.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (topicText != null && topicText.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '• $topicText',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              teacherNote,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _formatDate(homework.assignedDate ?? homework.createdAt),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}
