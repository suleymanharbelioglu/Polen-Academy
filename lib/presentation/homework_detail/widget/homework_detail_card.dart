import 'package:flutter/material.dart';
import 'package:polen_academy/core/utils/homework_ui_helper.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';

/// Ödev detay sayfasında listelenen ödev kartı. Renk ve metin helper'dan.
class HomeworkDetailCard extends StatelessWidget {
  const HomeworkDetailCard({
    super.key,
    required this.homework,
    required this.displayStatus,
  });

  final HomeworkEntity homework;
  final HomeworkSubmissionStatus displayStatus;

  @override
  Widget build(BuildContext context) {
    final color = HomeworkUiHelper.colorForStatus(displayStatus);
    final courseLabel = homework.courseName != null &&
            homework.courseName!.isNotEmpty
        ? homework.courseName!
        : (homework.courseId != null && homework.courseId!.isNotEmpty
            ? homework.courseId!
            : 'Ödev');
    final topicText = homework.topicNames.isNotEmpty
        ? homework.topicNames.join(' • ')
        : null;
    final hasDescription = homework.description.trim().isNotEmpty;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    courseLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    HomeworkUiHelper.typeLabel(homework.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (topicText != null && topicText.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text(
                'Konu:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                topicText,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (hasDescription) ...[
              const SizedBox(height: 8),
              const Text(
                'Açıklama / Serbest metin:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                homework.description.trim(),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (!hasDescription && (topicText == null || topicText.isEmpty))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Açıklama yok',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                HomeworkUiHelper.formatDate(
                  homework.assignedDate ?? homework.createdAt,
                ),
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
}
