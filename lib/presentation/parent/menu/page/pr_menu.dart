import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/bloc/logout_cubit.dart';
import 'package:polen_academy/common/bloc/logout_state.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/auth/page/welcome.dart';

class PrMenuPage extends StatelessWidget {
  const PrMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LogoutCubit(),
      child: const _PrMenuPageContent(),
    );
  }
}

class _PrMenuPageContent extends StatelessWidget {
  const _PrMenuPageContent();

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
              TargetsMenuItem(),
              SizedBox(height: 12),
              MeetingsMenuItem(),
              SizedBox(height: 12),
              RemainingTargetMenuItem(),
              Spacer(),
              LogoutMenuItem(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- HEDEFLER ----------------
class TargetsMenuItem extends StatelessWidget {
  const TargetsMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // AppNavigator.push(context, TargetsPage());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.secondBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: const [
            Icon(Icons.flag, color: AppColors.primaryParent),
            SizedBox(width: 16),
            Text(
              'Hedefler',
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

/// ---------------- GÖRÜŞMELER ----------------
class MeetingsMenuItem extends StatelessWidget {
  const MeetingsMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // AppNavigator.push(context, MeetingsPage());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.secondBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: const [
            Icon(Icons.handshake, color: AppColors.primaryParent),
            SizedBox(width: 16),
            Text(
              'Görüşmeler',
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

/// ---------------- HEDEFE KAÇ KALDI ----------------
class RemainingTargetMenuItem extends StatelessWidget {
  const RemainingTargetMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // AppNavigator.push(context, RemainingTargetPage());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.secondBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: const [
            Icon(Icons.timeline, color: AppColors.primaryParent),
            SizedBox(width: 16),
            Text(
              'Hedefe Kaç Kaldı ?',
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
              color: AppColors.primaryParent,
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
