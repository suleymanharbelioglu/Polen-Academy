import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/bloc/logout_cubit.dart';
import 'package:polen_academy/common/bloc/logout_state.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/auth/page/welcome.dart';
import 'package:polen_academy/presentation/student/profile/page/st_profile_page.dart';

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
        if (state is LogoutSuccess) {
          LoadingOverlay.hide(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppNavigator.pushAndRemove(context, const WelcomePage());
          });
        } else if (state is LogoutFailure) {
          LoadingOverlay.hide(context);
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
              ProfileMenuItem(),
              SizedBox(height: 12),
              Spacer(),
              LogoutMenuItem(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- PROFİLİM ----------------
class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const StProfilePage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.secondBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: const [
            Icon(Icons.person_outline, color: AppColors.primaryStudent),
            SizedBox(width: 16),
            Text(
              'Profilim',
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
                  LoadingOverlay.show(context);
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
                const Icon(Icons.logout, color: Colors.white),
                const SizedBox(width: 16),
                const Text(
                  'Çıkış Yap',
                  style: TextStyle(
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
