import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/bloc/coach_subscription_cubit.dart';
import 'package:polen_academy/core/configs/revenuecat_config.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/data/revenuecat/revenuecat_service.dart';
import 'package:polen_academy/presentation/coach/vip/bloc/vip_cubit.dart';
import 'package:polen_academy/presentation/coach/vip/bloc/vip_state.dart';
import 'package:polen_academy/service_locator.dart';

class VipPage extends StatelessWidget {
  const VipPage({super.key, this.suggestedStudents});

  /// Öğrenci limiti aşıldığında önerilen kota (ör. mevcut 5 → 10 öner).
  final int? suggestedStudents;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VipCubit(initialSelectedStudents: suggestedStudents),
      child: const _VipView(),
    );
  }
}

class _VipView extends StatelessWidget {
  const _VipView();

  static const _features = [
    'Detaylı Öğrenci Takibi ve Raporlama',
    'Haftalık ve Günlük Ödevlendirme',
    'Konu Bazlı Hedef Belirleme ve Takip',
  ];

  Future<void> _onPurchaseSuccess(BuildContext context) async {
    final coachUid = sl<AuthFirebaseService>().getCurrentUserUid();
    if (coachUid == null) return;
    await context.read<CoachSubscriptionCubit>().syncFromRevenueCat(coachUid);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aboneliğiniz aktif.'),
        backgroundColor: AppColors.primaryCoach,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: const Color(0xFF1D182A),
        title: const Text(
          'Planınızı Özelleştirin',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<VipCubit, VipState>(
        listenWhen: (prev, curr) => curr.errorMessage != null && prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeaderText(),
                    const SizedBox(height: 20),
                    _StudentSelectorCard(state: state),
                    const SizedBox(height: 16),
                    if (state.monthlyOption != null) ...[
                      _MonthlyPlanCard(
                        option: state.monthlyOption!,
                        onPurchase: () => _purchase(context, yearly: false),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (state.yearlyOption != null)
                      _YearlyPlanCard(
                        option: state.yearlyOption!,
                        onPurchase: () => _purchase(context, yearly: true),
                      ),
                    const SizedBox(height: 24),
                    const _FeaturesSection(features: _features),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: state.isPurchasing ? null : () => _restore(context),
                      child: const Text('Satın Alımları Geri Yükle'),
                    ),
                    if (!RevenueCatConfig.isConfigured)
                      _ConfigWarningBanner(),
                  ],
                ),
              ),
              if (state.isLoading || state.isPurchasing)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryCoach),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _purchase(BuildContext context, {required bool yearly}) async {
    final cubit = context.read<VipCubit>();
    final status = yearly ? await cubit.purchaseYearly() : await cubit.purchaseMonthly();
    if (status != null && status.isSubscribed && context.mounted) {
      final coachUid = sl<AuthFirebaseService>().getCurrentUserUid();
      if (coachUid != null) {
        await context.read<CoachSubscriptionCubit>().applyPurchaseResult(coachUid, status);
      }
      if (context.mounted) await _onPurchaseSuccess(context);
    }
  }

  Future<void> _restore(BuildContext context) async {
    final status = await context.read<VipCubit>().restorePurchases();
    if (status == null || !context.mounted) return;
    if (status.isSubscribed) {
      final coachUid = sl<AuthFirebaseService>().getCurrentUserUid();
      if (coachUid != null) {
        await context.read<CoachSubscriptionCubit>().applyPurchaseResult(coachUid, status);
      }
      if (context.mounted) await _onPurchaseSuccess(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geri yüklenecek aktif abonelik bulunamadı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _HeaderText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1D182A)),
            children: [
              const TextSpan(text: 'Planınızı '),
              TextSpan(
                text: 'Özelleştirin',
                style: TextStyle(
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF4F8CFF), AppColors.primaryCoach],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 30)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Öğrenci sayınıza göre başlayın. İstediğiniz zaman yükseltebilir veya düşürebilirsiniz.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}

class _StudentSelectorCard extends StatelessWidget {
  const _StudentSelectorCard({required this.state});

  final VipState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outline, color: AppColors.primaryCoach, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Öğrenci Sayısı Seçin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1D182A)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: state.availableTiers.contains(state.selectedStudents)
                    ? state.selectedStudents
                    : state.availableTiers.first,
                items: state.availableTiers
                    .map((tier) => DropdownMenuItem(
                          value: tier,
                          child: Text('$tier Öğrenci'),
                        ))
                    .toList(),
                onChanged: state.isPurchasing
                    ? null
                    : (value) {
                        if (value != null) {
                          context.read<VipCubit>().selectStudents(value);
                        }
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyPlanCard extends StatelessWidget {
  const _MonthlyPlanCard({required this.option, required this.onPurchase});

  final SubscriptionPackageOption option;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aylık Ödeme', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            option.pricePerMonthString,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1D182A)),
          ),
          const SizedBox(height: 4),
          Text(
            'Öğrenci başı ${option.pricePerStudentString}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          _GradientButton(
            label: 'Aylık Başla',
            colors: const [Color(0xFF4F8CFF), AppColors.primaryCoach],
            onTap: onPurchase,
          ),
        ],
      ),
    );
  }
}

class _YearlyPlanCard extends StatelessWidget {
  const _YearlyPlanCard({required this.option, required this.onPurchase});

  final SubscriptionPackageOption option;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '%${RevenueCatConfig.yearlyDiscountPercent} İNDİRİM',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text('Yıllık Ödeme', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            option.pricePerMonthString,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1D182A)),
          ),
          const SizedBox(height: 4),
          Text(
            'Öğrenci başı ${option.pricePerStudentString}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          if (option.yearlyTotalString != null) ...[
            const SizedBox(height: 4),
            Text(
              '(Yıllık Toplam: ${option.yearlyTotalString})',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          _GradientButton(
            label: 'Yıllık Başla (%${RevenueCatConfig.yearlyDiscountPercent} İndirimli)',
            colors: const [Color(0xFFE53935), AppColors.primaryCoach],
            onTap: onPurchase,
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.features});

  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tüm Özellikler Dahil',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1D182A)),
        ),
        const SizedBox(height: 12),
        ...features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(color: Color(0xFF43A047), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(feature, style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfigWarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade800),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'RevenueCat API anahtarları henüz yapılandırılmamış. '
              'lib/core/configs/revenuecat_config.dart dosyasını doldurun.',
              style: TextStyle(fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
