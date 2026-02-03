import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/auth/page/coach_sign_up.dart';
import 'package:polen_academy/presentation/coach/bottom_navbar/page/bottom_navbar.dart';

class CoachSignInPage extends StatelessWidget {
  const CoachSignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            const SizedBox(height: 16),

            Expanded(
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
                    children: [
                      // BACK
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          label: const Text(
                            'Geri',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // TITLE
                      const Text(
                        'Koç Girişi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),

                      const SizedBox(height: 24),

                      // GOOGLE LOGIN
                      OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(
                          Icons.g_mobiledata,
                          size: 28,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Google ile Hızlı Giriş',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // DIVIDER
                      Row(
                        children: const [
                          Expanded(child: Divider(color: Colors.grey)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'veya e-posta ile',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // EMAIL / PHONE
                      _inputLabel('E-posta'),
                      _inputField('ornek@email.com'),

                      const SizedBox(height: 16),

                      // PASSWORD
                      _inputLabel('Şifre'),
                      _inputField('Şifrenizi girin', obscure: true),

                      const SizedBox(height: 24),

                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            AppNavigator.pushAndRemove(
                              context,
                              BottomNavbarPage(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Giriş Yap',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // REGISTER
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.grey),
                          children: [
                            const TextSpan(text: 'Hesabınız yok mu? '),
                            TextSpan(
                              text: 'Şimdi Kaydolun',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  AppNavigator.push(context, CoachSignUpPage());
                                },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // FORGOT PASSWORD
                      const Text(
                        'Şifremi unuttum',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------- HELPERS --------

  static Widget _inputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  static Widget _inputField(String hint, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: TextField(
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
      ),
    );
  }
}
