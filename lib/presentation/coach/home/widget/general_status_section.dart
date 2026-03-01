import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';

class GeneralStatusSection extends StatelessWidget {
  const GeneralStatusSection({
    super.key,
    this.activeStudentCount = 0,
    this.overdueHomeworkCount = 0,
    this.pendingApprovalCount = 0,
  });

  final int activeStudentCount;
  final int overdueHomeworkCount;
  final int pendingApprovalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Genel Durum',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GeneralStatusItem(
                  title: 'Aktif\nÖğrenci',
                  value: activeStudentCount,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GeneralStatusItem(
                  title: 'Gecikmiş\nÖdev',
                  value: overdueHomeworkCount,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GeneralStatusItem(
                  title: 'Onay Bekleyen\nÖdev',
                  value: pendingApprovalCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GeneralStatusItem extends StatelessWidget {
  final String title;
  final int value;

  const GeneralStatusItem({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryCoach.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryCoach.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
