import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/auth/entity/student_credentials_entity.dart';

/// Dialog shown after a student is successfully created.
/// Displays the generated email and password (from [StudentCredentialsEntity]) with a security warning.
class StudentCredentialsDialog extends StatelessWidget {
  final StudentCredentialsEntity credentials;

  const StudentCredentialsDialog({super.key, required this.credentials});

  static Future<void> show(
    BuildContext context, {
    required StudentCredentialsEntity credentials,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StudentCredentialsDialog(credentials: credentials),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.secondBackground,
      title: const Text(
        'Öğrenci eklendi',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: const Text(
                'Lütfen öğrenci bilgilerinizi kaydedin. Güvenlik amacıyla bu bilgiler bir daha görünür olmayacaktır.',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Öğrenci giriş bilgileri (öğrenciyle paylaşın):',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            SelectableText(
              'E-posta: ${credentials.email}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            SelectableText(
              'Şifre: ${credentials.password}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Tamam',
            style: TextStyle(
              color: AppColors.primaryCoach,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
