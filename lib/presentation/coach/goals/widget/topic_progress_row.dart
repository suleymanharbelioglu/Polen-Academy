import 'package:flutter/material.dart';
import 'package:polen_academy/domain/curriculum/entity/topic_entity.dart';
import 'package:polen_academy/domain/goals/entity/topic_status.dart';
import 'package:polen_academy/presentation/coach/goals/widget/goals_status_box.dart';

class TopicProgressRow extends StatelessWidget {
  const TopicProgressRow({
    super.key,
    required this.topic,
    required this.konuStatus,
    required this.revisionStatus,
    required this.onKonuSelected,
    required this.onRevisionSelected,
  });

  final TopicEntity topic;
  final TopicStatus konuStatus;
  final TopicStatus revisionStatus;
  final void Function(TopicStatus) onKonuSelected;
  final void Function(TopicStatus) onRevisionSelected;

  static const double _colKonuWidth = 40;
  static const double _colTkrWidth = 40;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              topic.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            width: _colKonuWidth,
            child: Center(
              child: GoalsStatusBox(
                status: konuStatus,
                isUnit: false,
                onSelect: onKonuSelected,
              ),
            ),
          ),
          SizedBox(
            width: _colTkrWidth,
            child: Center(
              child: GoalsStatusBox(
                status: revisionStatus,
                isUnit: false,
                onSelect: onRevisionSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
