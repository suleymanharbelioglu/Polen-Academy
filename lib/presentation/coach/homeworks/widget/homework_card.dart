import 'package:flutter/material.dart';
import 'package:polen_academy/core/utils/homework_ui_helper.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';

/// Ödev kartı: renk HomeworkUiHelper'dan; üstte ders, konu, altta hocanın notu.
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

  @override
  Widget build(BuildContext context) {
    final color = HomeworkUiHelper.colorForStatus(displayStatus);
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
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
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
              Container(height: 0.5, color: Colors.white),
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
