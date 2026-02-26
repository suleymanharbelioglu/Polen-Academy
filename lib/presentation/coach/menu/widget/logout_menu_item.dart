import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/bloc/logout_cubit.dart';
import 'package:polen_academy/common/bloc/logout_state.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';

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
              color: AppColors.primaryCoach,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.logout, color: Colors.white),
                const SizedBox(width: 16),
                Text(
                  'Çıkış Yap',
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
