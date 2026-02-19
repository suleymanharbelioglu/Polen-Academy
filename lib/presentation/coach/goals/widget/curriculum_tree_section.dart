import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/goals/entity/topic_status.dart';
import 'package:polen_academy/presentation/coach/goals/widget/goals_status_box.dart';
import 'package:polen_academy/presentation/coach/goals/widget/topic_progress_row.dart';

class CurriculumTreeSection extends StatelessWidget {
  const CurriculumTreeSection({
    super.key,
    required this.courses,
    required this.getKonuStatus,
    required this.getRevisionStatus,
    required this.getUnitKonuStatus,
    required this.getUnitRevisionStatus,
    required this.onUpdateTopicProgress,
    required this.onUpdateUnitProgress,
  });

  final List<CourseWithUnits> courses;
  final TopicStatus Function(String topicId) getKonuStatus;
  final TopicStatus Function(String topicId) getRevisionStatus;
  final TopicStatus Function(UnitWithTopics unit) getUnitKonuStatus;
  final TopicStatus Function(UnitWithTopics unit) getUnitRevisionStatus;
  final void Function(String topicId, {TopicStatus? konuStatus, TopicStatus? revisionStatus}) onUpdateTopicProgress;
  final void Function(UnitWithTopics unit, {TopicStatus? konuStatus, TopicStatus? revisionStatus}) onUpdateUnitProgress;

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
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Card(
            margin: EdgeInsets.zero,
            color: AppColors.secondBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      courseWithUnits.course.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _tableHeader(),
                  const SizedBox(height: 8),
                  Divider(height: 1, color: Colors.white24),
                  const SizedBox(height: 10),
                  ...courseWithUnits.units.map((unitWithTopics) {
                    return _UnitExpansion(
                      unitWithTopics: unitWithTopics,
                      getKonuStatus: getKonuStatus,
                      getRevisionStatus: getRevisionStatus,
                      getUnitKonuStatus: getUnitKonuStatus,
                      getUnitRevisionStatus: getUnitRevisionStatus,
                      onUpdateTopicProgress: onUpdateTopicProgress,
                      onUpdateUnitProgress: onUpdateUnitProgress,
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static const double _colKonuWidth = 40;
  static const double _colTkrWidth = 40;

  Widget _tableHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Konu',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          width: _colKonuWidth,
          child: Text(
            'Konu',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: _colTkrWidth,
          child: Text(
            'Tkr.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _UnitExpansion extends StatelessWidget {
  const _UnitExpansion({
    required this.unitWithTopics,
    required this.getKonuStatus,
    required this.getRevisionStatus,
    required this.getUnitKonuStatus,
    required this.getUnitRevisionStatus,
    required this.onUpdateTopicProgress,
    required this.onUpdateUnitProgress,
  });

  final UnitWithTopics unitWithTopics;
  final TopicStatus Function(String topicId) getKonuStatus;
  final TopicStatus Function(String topicId) getRevisionStatus;
  final TopicStatus Function(UnitWithTopics unit) getUnitKonuStatus;
  final TopicStatus Function(UnitWithTopics unit) getUnitRevisionStatus;
  final void Function(String topicId, {TopicStatus? konuStatus, TopicStatus? revisionStatus}) onUpdateTopicProgress;
  final void Function(UnitWithTopics unit, {TopicStatus? konuStatus, TopicStatus? revisionStatus}) onUpdateUnitProgress;

  @override
  Widget build(BuildContext context) {
    final unitKonu = getUnitKonuStatus(unitWithTopics);
    final unitRevision = getUnitRevisionStatus(unitWithTopics);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.secondBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        controlAffinity: ListTileControlAffinity.leading,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        childrenPadding: const EdgeInsets.only(left: 28, right: 12, bottom: 12, top: 4),
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white70,
        title: Row(
          children: [
            Expanded(
              child: Text(
                unitWithTopics.unit.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: CurriculumTreeSection._colKonuWidth,
              child: Center(
                child: GoalsStatusBox(
                  status: unitKonu,
                  isUnit: true,
                  onSelect: (s) => onUpdateUnitProgress(unitWithTopics, konuStatus: s),
                ),
              ),
            ),
            SizedBox(
              width: CurriculumTreeSection._colTkrWidth,
              child: Center(
                child: GoalsStatusBox(
                  status: unitRevision,
                  isUnit: true,
                  onSelect: (s) => onUpdateUnitProgress(unitWithTopics, revisionStatus: s),
                ),
              ),
            ),
          ],
        ),
        children: unitWithTopics.topics.map((topic) {
          return TopicProgressRow(
            topic: topic,
            konuStatus: getKonuStatus(topic.id),
            revisionStatus: getRevisionStatus(topic.id),
            onKonuSelected: (s) => onUpdateTopicProgress(topic.id, konuStatus: s),
            onRevisionSelected: (s) => onUpdateTopicProgress(topic.id, revisionStatus: s),
          );
        }).toList(),
      ),
    );
  }
}
