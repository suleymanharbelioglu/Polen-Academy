import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/bloc/is_premium_cubit.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';

class VipPage extends StatefulWidget {
  const VipPage({super.key});

  @override
  State<VipPage> createState() => _VipPageState();
}

class _VipPageState extends State<VipPage> {
  bool _purchasing = false;
  Future<void> _purchase() async {
    setState(() => _purchasing = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    context.read<IsPremiumCubit>().activatePremium();
    setState(() => _purchasing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('VIP üyeliğiniz aktif.'),
        backgroundColor: AppColors.primaryCoach,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondBackground,
        elevation: 0,
        centerTitle: true,
        title: const Text('VIP Üyelik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Sınırsız öğrenci, öncelikli destek ve daha fazlası.',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                _VipPlanCard(
                  title: 'Aylık Plan',
                  price: '300',
                  period: '/ay',
                  description: 'İstediğiniz zaman iptal edebilirsiniz.',
                  features: const ['Sınırsız öğrenci', 'Tüm özelliklere erişim', 'Öncelikli destek'],
                  isPopular: false,
                  onTap: _purchase,
                ),
                const SizedBox(height: 16),
                _VipPlanCard(
                  title: 'Yıllık Plan',
                  price: '3.000',
                  period: '/yıl',
                  description: '2 ay bedava – en avantajlı seçenek.',
                  features: const ['Sınırsız öğrenci', 'Tüm özelliklere erişim', 'Öncelikli destek', 'Yıllık tasarruf'],
                  isPopular: true,
                  onTap: _purchase,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.secondBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: AppColors.primaryCoach),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Satın alma geçici olarak simüle edilir. Satın alma butonuna bastığınızda premium aktif olur.',
                          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_purchasing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: AppColors.primaryCoach)),
            ),
        ],
      ),
    );
  }
}

class _VipPlanCard extends StatelessWidget {
  const _VipPlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    required this.isPopular,
    required this.onTap,
  });

  final String title;
  final String price;
  final String period;
  final String description;
  final List<String> features;
  final bool isPopular;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPopular
                  ? [AppColors.primaryCoach, AppColors.primaryCoach.withOpacity(0.75), const Color(0xFF5B4BB8)]
                  : [AppColors.secondBackground, AppColors.secondBackground],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isPopular ? AppColors.primaryCoach : Colors.white24, width: isPopular ? 2 : 1),
            boxShadow: isPopular ? [BoxShadow(color: AppColors.primaryCoach.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (isPopular)
                Positioned(
                  top: -8,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
                    child: const Text('ÖNERİLEN', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(price, style: TextStyle(color: isPopular ? Colors.white : AppColors.primaryCoach, fontSize: 28, fontWeight: FontWeight.bold)),
                      Text(period, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(description, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                  const SizedBox(height: 16),
                  ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 18, color: isPopular ? Colors.white : AppColors.primaryCoach),
                        const SizedBox(width: 10),
                        Text(f, style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 14)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                  Center(child: Text('Seç', style: TextStyle(color: isPopular ? Colors.white : AppColors.primaryCoach, fontSize: 15, fontWeight: FontWeight.w600))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
