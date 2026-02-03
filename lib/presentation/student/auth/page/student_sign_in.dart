import 'package:flutter/material.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/student/bottom_navbar/page/student_bottom_navbar.dart';

class StudentSignInPage extends StatelessWidget {
  const StudentSignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                StudentSignInCard(),
                SizedBox(height: 24),
                BackToHomeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ================= SIGN IN CARD =================

class StudentSignInCard extends StatelessWidget {
  const StudentSignInCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SignInTitle(),
          SizedBox(height: 24),
          UsernameField(),
          SizedBox(height: 16),
          PasswordField(),
          SizedBox(height: 24),
          SignInButton(),
        ],
      ),
    );
  }
}

/// ================= TITLE =================

class SignInTitle extends StatelessWidget {
  const SignInTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Öğrenci Girişi',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

/// ================= USERNAME =================

class UsernameField extends StatelessWidget {
  const UsernameField({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputLabel(text: 'Kullanıcı Adı'),
        SizedBox(height: 6),
        InputField(hint: 'Kullanıcı Adınız'),
      ],
    );
  }
}

/// ================= PASSWORD =================

class PasswordField extends StatelessWidget {
  const PasswordField({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputLabel(text: 'Şifre'),
        SizedBox(height: 6),
        InputField(hint: 'Şifreniz', obscure: true),
      ],
    );
  }
}

/// ================= INPUT LABEL =================

class InputLabel extends StatelessWidget {
  final String text;

  const InputLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.white));
  }
}

/// ================= INPUT FIELD =================

class InputField extends StatelessWidget {
  final String hint;
  final bool obscure;

  const InputField({super.key, required this.hint, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
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
      ),
    );
  }
}

/// ================= SIGN IN BUTTON =================

class SignInButton extends StatelessWidget {
  const SignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          AppNavigator.pushReplacement(context, StudentBottomNavbarPage());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Giriş Yap',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// ================= BACK BUTTON =================

class BackToHomeButton extends StatelessWidget {
  const BackToHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        '← Ana Sayfaya Dön',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}
