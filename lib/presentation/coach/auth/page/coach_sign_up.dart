import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/auth/page/coach_sign_in.dart';

class CoachSignUpPage extends StatelessWidget {
  const CoachSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(height: 16),
                  _TitleSection(),
                  SizedBox(height: 24),
                  _FormSection(),
                  SizedBox(height: 24),
                  _NextButton(),
                  SizedBox(height: 16),
                  _LoginText(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _BackToHome(),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
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

class _FormSection extends StatelessWidget {
  const _FormSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _InputField(label: 'Ad', hint: 'Adınız'),
        SizedBox(height: 12),
        _InputField(label: 'Soyad', hint: 'Soyadınız'),
        SizedBox(height: 12),
        _InputField(
          label: 'E-posta',
          hint: 'E-posta adresiniz',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 12),
        _InputField(
          label: 'Telefon Numarası (İsteğe Bağlı)',
          hint: '5XX XXX XX XX',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType keyboardType;

  const _InputField({
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        TextField(
          keyboardType: keyboardType,
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
          ),
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Sonraki Adım',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _LoginText extends StatelessWidget {
  const _LoginText();

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
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                AppNavigator.push(context, CoachSignInPage());
              },
          ),
        ],
      ),
    );
  }
}

class _BackToHome extends StatelessWidget {
  const _BackToHome();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          '← Ana Sayfaya Dön',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
