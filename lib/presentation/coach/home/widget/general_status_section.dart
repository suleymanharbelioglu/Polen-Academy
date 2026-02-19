import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';

class GeneralStatusSection extends StatelessWidget {
  const GeneralStatusSection({
    super.key,
    this.activeStudentCount = 0,
    this.overdueHomeworkCount = 0,
    this.pendingApprovalCount = 0,
    this.unreadMessageCount = 0,
  });

  final int activeStudentCount;
  final int overdueHomeworkCount;
  final int pendingApprovalCount;
  final int unreadMessageCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Genel Durum',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GeneralStatusItem(
                  title: 'Aktif\nÖğrenci',
                  value: activeStudentCount,
                  valueColor: activeStudentCount > 0 ? Colors.white : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GeneralStatusItem(
                  title: 'Gecikmiş\nÖdev',
                  value: overdueHomeworkCount,
                  valueColor: overdueHomeworkCount > 0 ? Colors.orange : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GeneralStatusItem(
                  title: 'Onay\nBekleyen',
                  value: pendingApprovalCount,
                  valueColor: pendingApprovalCount > 0 ? Colors.amber : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GeneralStatusItem(
                  title: 'Okunmamış\nMesaj',
                  value: unreadMessageCount,
                  valueColor: unreadMessageCount > 0 ? Colors.white : Colors.grey,
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
  final Color valueColor;

  const GeneralStatusItem({
    super.key,
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
