import 'package:flutter/material.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/presentation/student/home/bloc/st_home_state.dart';

/// Öğrenci ödev kartı: onaylı=yeşil, onay bekliyor=mavi, eksik=turuncu, yapılmadı=kırmızı, bekleyen=gri.
class StHomeworkCard extends StatelessWidget {
  const StHomeworkCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final StHomeworkItem item;
  final VoidCallback? onTap;

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
    final color = colorForStatus(item.displayStatus);
    final h = item.homework;
    final courseLabel = h.courseName != null && h.courseName!.isNotEmpty
        ? h.courseName!
        : (h.courseId != null && h.courseId!.isNotEmpty ? h.courseId! : 'Ödev');
    final topicText = h.topicNames.isNotEmpty ? h.topicNames.join(' • ') : null;
    final teacherNote = h.description.isEmpty ? 'Ödev' : h.description;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
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
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                teacherNote,
                style: const TextStyle(color: Colors.white, fontSize: 13),
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
