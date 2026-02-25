import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';

class SetPasswordDialog extends StatefulWidget {
  const SetPasswordDialog({
    super.key,
    required this.title,
    required this.formKey,
    required this.controller,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;

  @override
  State<SetPasswordDialog> createState() => _SetPasswordDialogState();
}

class _SetPasswordDialogState extends State<SetPasswordDialog> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.secondBackground,
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: Form(
        key: widget.formKey,
        child: TextFormField(
          controller: widget.controller,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Yeni şifre',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryCoach),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Şifre gerekli';
            if (v.length < 6) return 'En az 6 karakter olmalı';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.formKey.currentState!.validate()) {
              Navigator.pop(context, widget.controller.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryCoach),
          child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

Future<void> showNewPasswordInfoDialog(BuildContext context, String newPassword) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.secondBackground,
      title: const Text(
        'Şifre güncellendi',
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
                'Lütfen yeni şifreyi ilgili kişiyle paylaşın. Güvenlik amacıyla bu bilgi bir daha görünür olmayacaktır.',
                style: TextStyle(color: Colors.amber, fontSize: 14, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Yeni şifre:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SelectableText(
              newPassword,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Tamam',
            style: TextStyle(color: AppColors.primaryCoach, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
