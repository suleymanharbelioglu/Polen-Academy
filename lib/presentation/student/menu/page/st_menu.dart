import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/bloc/logout_cubit.dart';
import 'package:polen_academy/common/bloc/logout_state.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/auth/page/welcome.dart';

class StMenuPage extends StatelessWidget {
  const StMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LogoutCubit(),
      child: const _StMenuPageContent(),
    );
  }
}

class _StMenuPageContent extends StatelessWidget {
  const _StMenuPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutCubit, LogoutState>(
      listener: (context, state) {
        print('🔔 Logout State değişti: ${state.runtimeType}');
        if (state is LogoutSuccess) {
          print('✅ Logout Success state alındı, yönlendiriliyor...');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppNavigator.pushAndRemove(context, const WelcomePage());
          });
        } else if (state is LogoutFailure) {
          print('❌ Logout Failure state: ${state.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              SizedBox(height: 12),
              ExamsMenuItem(),
              SizedBox(height: 12),
              QuestionTrackingMenuItem(),
              Spacer(),
              LogoutMenuItem(),
            ],
          ),
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
            Icon(Icons.bar_chart, color: AppColors.primaryStudent),
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
            Icon(Icons.track_changes, color: AppColors.primaryStudent),
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
    return BlocBuilder<LogoutCubit, LogoutState>(
      builder: (context, state) {
        final isLoading = state is LogoutLoading;

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading
              ? null
              : () {
                  print('🚪 Logout butonu tıklandı');
                  context.read<LogoutCubit>().logout();
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.primaryStudent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                if (isLoading)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  const Icon(Icons.logout, color: Colors.white),
                const SizedBox(width: 16),
                Text(
                  isLoading ? 'Çıkış yapılıyor...' : 'Çıkış Yap',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
