import 'package:flutter/material.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';

/// Ödev kartı: tüm kart durum rengi, üstte ders, konu, altta hocanın notu; tüm yazılar beyaz.
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
        return Colors.orange; // Onay Bekliyor - öğrenci ekleme yapmış, turuncu
      case HomeworkSubmissionStatus.missing:
        return Colors.amber; // Eksik - sarı
      case HomeworkSubmissionStatus.notDone:
        return Colors.red;
      case HomeworkSubmissionStatus.pending:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForStatus(displayStatus);
    final courseLabel = homework.courseName != null && homework.courseName!.isNotEmpty
        ? homework.courseName!
        : (homework.courseId != null && homework.courseId!.isNotEmpty
            ? homework.courseId!
            : 'Ödev');
    final topicText = homework.topicNames.isNotEmpty
        ? homework.topicNames.join(' • ')
        : null;
    final teacherNote = homework.description.isEmpty ? 'Ödev' : homework.description;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
            ],
          ),
        ),
      ),
    );
  }
}
