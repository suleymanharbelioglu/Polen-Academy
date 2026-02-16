import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/model/coach_signin_req.dart';
import 'package:polen_academy/presentation/coach/auth/bloc/coach_signin_cubit.dart';
import 'package:polen_academy/presentation/coach/auth/bloc/coach_signin_state.dart';
import 'package:polen_academy/presentation/coach/auth/widget/coach_sign_in_widgets.dart';
import 'package:polen_academy/presentation/coach/bottom_navbar/page/bottom_navbar.dart';

class CoachSignInPage extends StatelessWidget {
  const CoachSignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoachSigninCubit(),
      child: const _CoachSignInPageContent(),
    );
  }
}

class _CoachSignInPageContent extends StatefulWidget {
  const _CoachSignInPageContent();

  @override
  State<_CoachSignInPageContent> createState() =>
      _CoachSignInPageContentState();
}

class _CoachSignInPageContentState extends State<_CoachSignInPageContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: 'harba.suleyman@gmail.com',
  );
  final _passwordController = TextEditingController(text: 'cmylmz.31');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      final req = CoachSigninReq(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      context.read<CoachSigninCubit>().signIn(req);
    }
  }

  void _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNavigator.pushAndRemove(context, const BottomNavbarPage());
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoachSigninCubit, CoachSigninState>(
      listener: (context, state) {
        if (state is CoachSigninSuccess) {
          _navigateToHome();
        } else if (state is CoachSigninFailure) {
          _showError(state.errorMessage);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.secondBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CoachSignInTitleSection(),
                          const SizedBox(height: 24),
                          CoachSignInFormSection(
                            emailController: _emailController,
                            passwordController: _passwordController,
                          ),
                          const SizedBox(height: 24),
                          CoachSignInLoginButton(onPressed: _handleSignIn),
                          const SizedBox(height: 16),
                          const CoachSignInBottomTexts(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
