import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/bloc/is_premium_cubit.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/vip/page/vip_page.dart';

/// Koç menüsünün üstünde VIP durumunu gösteren kart. Tıklanınca VIP sayfasına gider.
class VipCard extends StatelessWidget {
  const VipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IsPremiumCubit, bool>(
      builder: (context, isPremium) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final activated = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const VipPage()),
                );
                if (activated == true && context.mounted) {
                  context.read<IsPremiumCubit>().activatePremium();
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isPremium
                        ? [
                            AppColors.primaryCoach,
                            AppColors.primaryCoach.withOpacity(0.8),
                            const Color(0xFF5B4BB8),
                          ]
                        : [
                            AppColors.secondBackground,
                            const Color(0xFF2A2535),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPremium ? AppColors.primaryCoach.withOpacity(0.6) : Colors.white12,
                    width: 1,
                  ),
                  boxShadow: [
                    if (isPremium)
                      BoxShadow(
                        color: AppColors.primaryCoach.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isPremium ? Colors.white : AppColors.primaryCoach).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isPremium ? Icons.workspace_premium : Icons.star_border_rounded,
                        color: isPremium ? Colors.amber : AppColors.primaryCoach,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPremium ? 'VIP Üye' : 'VIP\'e Geçin',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPremium
                                ? 'Sınırsız öğrenci ve tüm avantajlar aktif.'
                                : 'Sınırsız öğrenci ekleyin, avantajlardan yararlanın.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
