import 'package:flutter/material.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/auth/page/welcome.dart';

class StMenuPage extends StatelessWidget {
  const StMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            StudentsMenuItem(),
            SizedBox(height: 12),
            ExamsMenuItem(),
            SizedBox(height: 12),
            QuestionTrackingMenuItem(),
            Spacer(),
            LogoutMenuItem(),
          ],
        ),
      ),
    );
  }
}

/// ---------------- ÖĞRENCİLERİM ----------------
class StudentsMenuItem extends StatelessWidget {
  const StudentsMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Navigator.push(...)
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.secondBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: const [
            Icon(Icons.people, color: AppColors.primary),
            SizedBox(width: 16),
            Text(
              'Öğrencilerim',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// ---------------- DENEMELER ----------------
class ExamsMenuItem extends StatelessWidget {
  const ExamsMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.secondBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: const [
            Icon(Icons.bar_chart, color: AppColors.primary),
            SizedBox(width: 16),
            Text(
              'Denemeler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// ---------------- SORU TAKİBİ ----------------
class QuestionTrackingMenuItem extends StatelessWidget {
  const QuestionTrackingMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.secondBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: const [
            Icon(Icons.track_changes, color: AppColors.primary),
            SizedBox(width: 16),
            Text(
              'Soru Takibi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// ---------------- ÇIKIŞ YAP ----------------
class LogoutMenuItem extends StatelessWidget {
  const LogoutMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        AppNavigator.pushAndRemove(context, WelcomePage());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.primary, // ✅ PRIMARY ARKA PLAN
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: const [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 16),
            Text(
              'Çıkış Yap',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
