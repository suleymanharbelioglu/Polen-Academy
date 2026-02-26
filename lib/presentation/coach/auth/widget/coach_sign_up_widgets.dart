import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/auth/bloc/coach_creation_req_state.dart';
import 'package:polen_academy/presentation/coach/auth/bloc/coach_cretation_req_cubit.dart';
import 'package:polen_academy/presentation/coach/auth/page/coach_sign_in.dart';

// Back to Home
class CoachSignUpBackToHome extends StatelessWidget {
  const CoachSignUpBackToHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          '← Ana Sayfaya Dön',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

// Title Section
class CoachSignUpTitleSection extends StatelessWidget {
  const CoachSignUpTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Bireysel Koç Olarak\nKaydol',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}

// Form Section
class CoachSignUpFormSection extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const CoachSignUpFormSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CoachSignUpInputField(
          label: 'Ad',
          hint: 'Adınız',
          controller: firstNameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ad alanı boş olamaz';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        CoachSignUpInputField(
          label: 'Soyad',
          hint: 'Soyadınız',
          controller: lastNameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Soyad alanı boş olamaz';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        CoachSignUpInputField(
          label: 'E-posta',
          hint: 'E-posta adresiniz',
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
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
        const SizedBox(height: 12),
        CoachSignUpInputField(
          label: 'Şifre',
          hint: 'Şifreniz (en az 6 karakter)',
          controller: passwordController,
          obscureText: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Şifre alanı boş olamaz';
            }
            if (value.length < 6) {
              return 'Şifre en az 6 karakter olmalıdır';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// Input Field
class CoachSignUpInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;

  const CoachSignUpInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}

// Next Button
class CoachSignUpNextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CoachSignUpNextButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachCretationReqCubit, CoachCreationReqState>(
      builder: (context, state) {
        final isLoading = state is CoachCreationReqLoading;

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
            child: const Text(
              'Kayıt Ol',
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

// Login Text
class CoachSignUpLoginText extends StatelessWidget {
  const CoachSignUpLoginText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.grey),
        children: [
          const TextSpan(text: 'Zaten bir hesabınız var mı? '),
          TextSpan(
            text: 'Giriş Yapın',
            style: const TextStyle(
              color: AppColors.primaryCoach,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                AppNavigator.push(context, const CoachSignInPage());
              },
          ),
        ],
      ),
    );
  }
}
