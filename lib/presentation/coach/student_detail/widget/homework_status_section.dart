import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';

class HomeworkStatusSection extends StatelessWidget {
  const HomeworkStatusSection({
    super.key,
    required this.state,
    this.onDetailsTap,
  });

  final StudentDetailState state;
  final VoidCallback? onDetailsTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onDetailsTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Ödev Durumları',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Detaylar için tıklayın',
                    style: const TextStyle(
                      color: AppColors.primaryCoach,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatusCard(
                      label: 'YAPILAN',
                      value: state.completedHomeworkCount,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatusCard(
                      label: 'GECİKEN',
                      value: state.overdueCount,
                      color: const Color(0xFF8D6E63),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatusCard(
                      label: 'EKSİK',
                      value: state.missingCount,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatusCard(
                      label: 'YAPILMADI',
                      value: state.notDoneCount,
                      color: Colors.deepOrange.shade300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle = 'ödev',
  });

  final String label;
  final int value;
  final Color color;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
