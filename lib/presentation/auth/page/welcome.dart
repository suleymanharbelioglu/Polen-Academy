import 'package:flutter/material.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/auth/page/coach_sign_in.dart';
import 'package:polen_academy/presentation/coach/auth/page/coach_sign_up.dart';
import 'package:polen_academy/presentation/parent/auth/page/parent_sign_in.dart';
import 'package:polen_academy/presentation/student/auth/page/student_sign_in.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Polen Academy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => _showLoginSheet(context),
            child: const Text('Giriş Yap', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () =>
                  AppNavigator.push(context, const CoachSignUpPage()),
              child: const Text('Kaydol'),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Giriş Türünü Seç',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _LoginOption(
              icon: Icons.school,
              title: 'Öğrenci Girişi',
              onTap: () {
                Navigator.of(context).pop();
                AppNavigator.push(context, const StudentSignInPage());
              },
            ),
            const SizedBox(height: 16),
            _LoginOption(
              icon: Icons.person,
              title: 'Veli Girişi',
              onTap: () {
                Navigator.of(context).pop();
                AppNavigator.push(context, const ParentSignInPage());
              },
            ),
            const SizedBox(height: 16),
            _LoginOption(
              icon: Icons.psychology,
              title: 'Koç Girişi',
              onTap: () {
                Navigator.of(context).pop();
                AppNavigator.push(context, const CoachSignInPage());
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LoginOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _LoginOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
