import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/homework_status_section.dart';

/// Ödev durumları ile aynı mantıkta: Yapılan seanslar, Yapılmayan seanslar, Gelecek seanslar.
class SessionStatusSection extends StatelessWidget {
  const SessionStatusSection({
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
                    'Seans Durumları',
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
                      value: state.completedSessions.length,
                      color: const Color(0xFF4CAF50),
                      subtitle: 'seans',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatusCard(
                      label: 'YAPILMAYAN',
                      value: state.notDoneSessions.length,
                      color: const Color(0xFFE53935),
                      subtitle: 'seans',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatusCard(
                      label: 'GELECEK',
                      value: state.futureSessions.length,
                      color: const Color(0xFF42A5F5),
                      subtitle: 'seans',
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
