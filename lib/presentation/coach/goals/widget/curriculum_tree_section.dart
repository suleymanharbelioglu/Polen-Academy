import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/presentation/coach/goals/widget/topic_progress_row.dart';

class CurriculumTreeSection extends StatelessWidget {
  const CurriculumTreeSection({
    super.key,
    required this.courses,
    required this.isKonuStudied,
    required this.isRevisionDone,
    required this.onUpdateKonu,
    required this.onUpdateRevision,
  });

  final List<CourseWithUnits> courses;
  final bool Function(String topicId) isKonuStudied;
  final bool Function(String topicId) isRevisionDone;
  final void Function(String topicId, bool value) onUpdateKonu;
  final void Function(String topicId, bool value) onUpdateRevision;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Bu sınıf için müfredat bulunamadı.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, courseIndex) {
        final courseWithUnits = courses[courseIndex];
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.only(left: 16, bottom: 12),
            collapsedBackgroundColor: AppColors.secondBackground.withOpacity(0.5),
            backgroundColor: AppColors.secondBackground.withOpacity(0.3),
            title: Text(
              courseWithUnits.course.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: courseWithUnits.units.map((unitWithTopics) {
              return ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
                title: Text(
                  unitWithTopics.unit.name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: unitWithTopics.topics.map((topic) {
                  return TopicProgressRow(
                    topic: topic,
                    konuStudied: isKonuStudied(topic.id),
                    revisionDone: isRevisionDone(topic.id),
                    onKonuChanged: (v) => onUpdateKonu(topic.id, v),
                    onRevisionChanged: (v) => onUpdateRevision(topic.id, v),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
