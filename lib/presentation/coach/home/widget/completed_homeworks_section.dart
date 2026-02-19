import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';

class CompletedHomeworkSection extends StatelessWidget {
  const CompletedHomeworkSection({
    super.key,
    this.items = const [],
    required this.onTap,
    required this.onRefresh,
  });

  final List<CompletedHomeworkItem> items;
  final void Function(CompletedHomeworkItem item) onTap;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final byStudent = <String, List<CompletedHomeworkItem>>{};
    for (final item in items) {
      byStudent.putIfAbsent(item.studentName, () => []).add(item);
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
            children: const [
              Text(
                'Tamamlanan Ödevler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Tamamlanan ödev yok.',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            )
          else
            ...entries.map((e) => _StudentHomeworkGroup(
                  studentName: e.key,
                  itemList: e.value,
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
    required this.itemList,
    required this.onTap,
  });

  final String studentName;
  final List<CompletedHomeworkItem> itemList;
  final void Function(CompletedHomeworkItem item) onTap;

  @override
  State<_StudentHomeworkGroup> createState() => _StudentHomeworkGroupState();
}

class _StudentHomeworkGroupState extends State<_StudentHomeworkGroup> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final count = widget.itemList.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
                    '$count adet',
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
            ...widget.itemList.map((item) => _HomeworkTile(
                  item: item,
                  onTap: () => widget.onTap(item),
                )),
        ],
      ),
    );
  }
}

class _HomeworkTile extends StatelessWidget {
  const _HomeworkTile({required this.item, required this.onTap});

  final CompletedHomeworkItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = item.homework;
    final title = h.description.isNotEmpty ? h.description : 'Ödev';
    final short = title.length > 50 ? '${title.substring(0, 50)}...' : title;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    short,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  if (h.courseId != null && h.courseId!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        h.courseId!,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54, size: 22),
          ],
        ),
      ),
    );
  }
}
