import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/auth/page/welcome.dart';
import 'package:polen_academy/presentation/coach/bottom_navbar/page/bottom_navbar.dart';
import 'package:polen_academy/presentation/splash/bloc/splash_cubit.dart';
import 'package:polen_academy/presentation/splash/bloc/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is UnAuthenticated) {
          AppNavigator.pushAndRemove(context, WelcomePage());
        }
        if (state is Authenticated) {
          AppNavigator.pushAndRemove(context, BottomNavbarPage());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(child: Text("Polen Academy")),
      ),
    );
  }
}
