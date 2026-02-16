import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/auth/page/welcome.dart';
import 'package:polen_academy/presentation/coach/bottom_navbar/page/bottom_navbar.dart';
import 'package:polen_academy/presentation/parent/bottom_navbar/page/pr_bottom_navbar.dart';
import 'package:polen_academy/presentation/splash/bloc/splash_cubit.dart';
import 'package:polen_academy/presentation/splash/bloc/splash_state.dart';
import 'package:polen_academy/presentation/student/bottom_navbar/page/student_bottom_navbar.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is UnAuthenticated) {
          AppNavigator.pushAndRemove(context, const WelcomePage());
        }
        if (state is Authenticated) {
          switch (state.role) {
            case 'coach':
              AppNavigator.pushAndRemove(context, const BottomNavbarPage());
              break;
            case 'student':
              AppNavigator.pushAndRemove(context, const StudentBottomNavbarPage());
              break;
            case 'parent':
              AppNavigator.pushAndRemove(context, const PrBottomNavbarPage());
              break;
            default:
              AppNavigator.pushAndRemove(context, const WelcomePage());
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: const Center(
          child: Text(
            'Polen Academy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
