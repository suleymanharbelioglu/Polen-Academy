import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';

class DailyAgendaSection extends StatelessWidget {
  const DailyAgendaSection({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Günün Ajandası',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.info_outline, size: 18, color: Colors.grey),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                label: const Text(
                  'Seans Planla',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 80), // içerik alanı (boş)
        ],
      ),
    );
  }
}
