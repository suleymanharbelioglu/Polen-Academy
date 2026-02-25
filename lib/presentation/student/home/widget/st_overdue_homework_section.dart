import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/student/home/bloc/st_home_state.dart';
import 'package:polen_academy/presentation/student/home/widget/st_homework_card.dart';

class StOverdueHomeworkSection extends StatelessWidget {
  const StOverdueHomeworkSection({
    super.key,
    required this.items,
    this.onTap,
  });

  final List<StHomeworkItem> items;
  final void Function(StHomeworkItem)? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              Icon(Icons.schedule, color: Colors.deepOrange.shade300, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Gecikmiş Ödevlerim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Gecikmiş ödev yok.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            )
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: StHomeworkCard(
                    item: item,
                    onTap: onTap != null ? () => onTap!(item) : null,
                  ),
                )),
        ],
      ),
    );
  }
}
