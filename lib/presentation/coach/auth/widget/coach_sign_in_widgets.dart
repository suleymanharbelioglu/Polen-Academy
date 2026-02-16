import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/auth/bloc/coach_signin_cubit.dart';
import 'package:polen_academy/presentation/coach/auth/bloc/coach_signin_state.dart';
import 'package:polen_academy/presentation/coach/auth/page/coach_sign_up.dart';

// Title Section
class CoachSignInTitleSection extends StatelessWidget {
  const CoachSignInTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Colors.grey,
            ),
            label: const Text('Geri', style: TextStyle(color: Colors.grey)),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Koç Girişi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

// Form Section
class CoachSignInFormSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const CoachSignInFormSection({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CoachSignInInputLabel(text: 'E-posta'),
        CoachSignInInputField(
          hint: 'ornek@email.com',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'E-posta alanı boş olamaz';
            }
            final emailRegex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            );
            if (!emailRegex.hasMatch(value.trim())) {
              return 'Geçerli bir e-posta adresi girin';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        const CoachSignInInputLabel(text: 'Şifre'),
        CoachSignInInputField(
          hint: 'Şifrenizi girin',
          obscure: true,
          controller: passwordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Şifre alanı boş olamaz';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// Input Field
class CoachSignInInputField extends StatelessWidget {
  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CoachSignInInputField({
    super.key,
    required this.hint,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}

// Input Label
class CoachSignInInputLabel extends StatelessWidget {
  final String text;

  const CoachSignInInputLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Login Button
class CoachSignInLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CoachSignInLoginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachSigninCubit, CoachSigninState>(
      builder: (context, state) {
        final isLoading = state is CoachSigninLoading;

        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCoach,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Giriş Yap',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// Bottom Texts
class CoachSignInBottomTexts extends StatelessWidget {
  const CoachSignInBottomTexts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.grey),
            children: [
              const TextSpan(text: 'Hesabınız yok mu? '),
              TextSpan(
                text: 'Şimdi Kaydolun',
                style: const TextStyle(
                  color: AppColors.primaryCoach,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    AppNavigator.push(context, const CoachSignUpPage());
                  },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Şifremi unuttum',
          style: TextStyle(
            color: AppColors.primaryCoach,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
