import 'package:flutter/material.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/homeworks/widget/homework_card.dart';

class CompletedHomeworkSection extends StatelessWidget {
  const CompletedHomeworkSection({
    super.key,
    this.items = const [],
    this.title = 'Onay Bekleyen Ödevler',
    this.subtitle = '',
    this.emptyMessage = 'Onay bekleyen ödev yok.',
    required this.onTap,
    required this.onRefresh,
  });

  final List<CompletedHomeworkItem> items;
  final String title;
  final String subtitle;
  final String emptyMessage;
  final void Function(CompletedHomeworkItem item) onTap;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    // Öğrenci -> Ders etiketi -> Ödev listesi
    final byStudent = <String, Map<String, List<CompletedHomeworkItem>>>{};
    for (final item in items) {
      final courseLabel = item.homework.courseName != null && item.homework.courseName!.isNotEmpty
          ? item.homework.courseName!
          : (item.homework.courseId != null && item.homework.courseId!.isNotEmpty
              ? item.homework.courseId!
              : 'Ödev');
      byStudent
          .putIfAbsent(item.studentName, () => {})
          .putIfAbsent(courseLabel, () => [])
          .add(item);
    }
    final entries = byStudent.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(height: 1, color: Colors.white),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  emptyMessage,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            )
          else
            ...entries.map((e) => _StudentHomeworkGroup(
                  studentName: e.key,
                  courseToItems: e.value,
                  onTap: onTap,
                )),
        ],
      ),
    );
  }
}

class _StudentHomeworkGroup extends StatefulWidget {
  const _StudentHomeworkGroup({
    required this.studentName,
    required this.courseToItems,
    required this.onTap,
  });

  final String studentName;
  final Map<String, List<CompletedHomeworkItem>> courseToItems;
  final void Function(CompletedHomeworkItem item) onTap;

  @override
  State<_StudentHomeworkGroup> createState() => _StudentHomeworkGroupState();
}

class _StudentHomeworkGroupState extends State<_StudentHomeworkGroup> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final totalCount = widget.courseToItems.values.fold<int>(0, (sum, list) => sum + list.length);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.studentName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    '$totalCount adet',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.courseToItems.entries.map((courseEntry) {
                  final courseLabel = courseEntry.key;
                  final itemList = courseEntry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
                        child: Text(
                          courseLabel.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...itemList.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: HomeworkCard(
                              homework: item.homework,
                              displayStatus: item.submission.status,
                              onTap: () => widget.onTap(item),
                            ),
                          )),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
