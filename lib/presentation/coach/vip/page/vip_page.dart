import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/data/revenuecat/revenuecat_service.dart';
import 'package:polen_academy/service_locator.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class VipPage extends StatefulWidget {
  const VipPage({super.key});

  @override
  State<VipPage> createState() => _VipPageState();
}

class _VipPageState extends State<VipPage> {
  Offerings? _offerings;
  bool _loading = true;
  bool _purchasing = false;
  final _rc = RevenueCatService();

  @override
  void initState() {
    super.initState();
    _initAndLoadOfferings();
  }

  Future<void> _initAndLoadOfferings() async {
    final uid = sl<AuthFirebaseService>().getCurrentUserUid();
    if (uid == null || uid.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    await _rc.configure(uid);
    final offerings = await _rc.getOfferings();
    if (mounted) {
      setState(() {
        _offerings = offerings;
        _loading = false;
      });
    }
  }

  Package? get _monthlyPackage {
    final current = _offerings?.current;
    if (current == null) return null;
    final list = current.availablePackages.where((p) => p.packageType == PackageType.monthly).toList();
    return list.isEmpty ? null : list.first;
  }

  Package? get _annualPackage {
    final current = _offerings?.current;
    if (current == null) return null;
    final list = current.availablePackages.where((p) => p.packageType == PackageType.annual).toList();
    return list.isEmpty ? null : list.first;
  }

  Future<void> _purchase(Package? package) async {
    if (package == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu plan şu an kullanılamıyor.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final uid = sl<AuthFirebaseService>().getCurrentUserUid();
    if (uid == null) return;
    setState(() => _purchasing = true);
    final error = await _rc.purchasePackage(package, uid);
    if (!mounted) return;
    setState(() => _purchasing = false);
    if (error != null && error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('VIP üyeliğiniz aktif.'), backgroundColor: AppColors.primaryCoach, behavior: SnackBarBehavior.floating),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _restore() async {
    final uid = sl<AuthFirebaseService>().getCurrentUserUid();
    if (uid == null) return;
    setState(() => _purchasing = true);
    final error = await _rc.restorePurchases(uid);
    if (!mounted) return;
    setState(() => _purchasing = false);
    if (error != null && error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Satın almalar geri yüklendi.'), backgroundColor: AppColors.primaryCoach, behavior: SnackBarBehavior.floating),
      );
      Navigator.of(context).pop(true);
    }
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
        actions: [
          if (!_loading && !_purchasing)
            TextButton(
              onPressed: _restore,
              child: const Text('Geri yükle', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryCoach))
          : Stack(
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
                        price: _monthlyPackage?.storeProduct.priceString ?? '300',
                        period: '/ay',
                        description: 'İstediğiniz zaman iptal edebilirsiniz.',
                        features: const ['Sınırsız öğrenci', 'Tüm özelliklere erişim', 'Öncelikli destek'],
                        isPopular: false,
                        onTap: () => _purchase(_monthlyPackage),
                      ),
                      const SizedBox(height: 16),
                      _VipPlanCard(
                        title: 'Yıllık Plan',
                        price: _annualPackage?.storeProduct.priceString ?? '3.000',
                        period: '/yıl',
                        description: '2 ay bedava – en avantajlı seçenek.',
                        features: const ['Sınırsız öğrenci', 'Tüm özelliklere erişim', 'Öncelikli destek', 'Yıllık tasarruf'],
                        isPopular: true,
                        onTap: () => _purchase(_annualPackage),
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
                                'Ödeme RevenueCat ile güvenli altyapıda yapılır. İstediğiniz zaman iptal edebilirsiniz.',
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
