import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/bloc/logout_cubit.dart';
import 'package:polen_academy/common/bloc/logout_state.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/auth/page/welcome.dart';
import 'package:polen_academy/presentation/coach/menu/widget/logout_menu_item.dart';
import 'package:polen_academy/presentation/coach/menu/widget/students_menu_item.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LogoutCubit(),
      child: const _MenuPageContent(),
    );
  }
}

class _MenuPageContent extends StatelessWidget {
  const _MenuPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutCubit, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppNavigator.pushAndRemove(context, const WelcomePage());
          });
        } else if (state is LogoutFailure) {
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
              StudentsMenuItem(),
              Spacer(),
              LogoutMenuItem(),
            ],
          ),
        ),
      ),
    );
  }
}
