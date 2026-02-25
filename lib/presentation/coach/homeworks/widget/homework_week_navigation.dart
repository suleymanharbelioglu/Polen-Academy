import 'package:flutter/material.dart';

class HomeworkWeekNavigation extends StatelessWidget {
  const HomeworkWeekNavigation({
    super.key,
    required this.weekRangeLabel,
    this.weekNumber,
    required this.onPrevious,
    required this.onNext,
    this.onPrint,
    this.onAddWeekly,
    this.showAddWeekly = true,
  });

  final String weekRangeLabel;
  /// null ise tarihin yanında hafta numarası gösterilmez (kayıt öncesi haftalar).
  final int? weekNumber;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onPrint;
  final VoidCallback? onAddWeekly;
  final bool showAddWeekly;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: onPrevious,
        ),
        Expanded(
          child: Text(
            weekNumber != null ? '$weekRangeLabel ($weekNumber. Hafta)' : weekRangeLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white),
          onPressed: onNext,
        ),
        if (onPrint != null)
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white54),
            onPressed: onPrint,
          ),
        if (showAddWeekly && onAddWeekly != null)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Material(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: onAddWeekly,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Haftalık Ödev',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
