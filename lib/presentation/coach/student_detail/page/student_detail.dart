import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/widget/add_parent_dialog.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/common/widget/parent_credentials_dialog.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/auth/entity/parent_credentials_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/usecases/delete_student.dart';
import 'package:polen_academy/domain/user/usecases/update_user_password.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/current_student_cubit.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/parent_signup_cubit.dart';
import 'package:polen_academy/service_locator.dart';

class StudentDetailPage extends StatelessWidget {
  const StudentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondBackground,
        foregroundColor: Colors.white,
        title: const Text('Öğrenci detayı'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<CurrentStudentCubit, StudentEntity?>(
        builder: (context, student) {
          if (student == null) {
            return const Center(
              child: Text(
                'Öğrenci bilgisi yok',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoCard(student: student),
                const SizedBox(height: 24),
                if (!student.hasParent) _AddParentButton(student: student),
                const SizedBox(height: 16),
                _SetNewPasswordButton(
                  userId: student.uid,
                  label: 'Öğrenciye yeni şifre ver',
                ),
                if (student.hasParent) ...[
                  const SizedBox(height: 8),
                  _SetNewPasswordButton(
                    userId: student.parentId,
                    label: 'Veliye yeni şifre ver',
                  ),
                ],
                const SizedBox(height: 24),
                _DeleteStudentButton(student: student),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Ad', value: student.studentName),
            _InfoRow(label: 'Soyad', value: student.studentSurname),
            _InfoRow(label: 'Sınıf', value: student.studentClass),
            _InfoRow(label: 'E-posta', value: student.email),
            _InfoRow(label: 'İlerleme', value: '${student.progress}%'),
            _InfoRow(
              label: 'Veli',
              value: student.hasParent ? 'Atandı' : 'Atanmadı',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddParentButton extends StatelessWidget {
  const _AddParentButton({required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _openAddParentDialog(context),
      icon: const Icon(Icons.person_add, color: Colors.white),
      label: const Text(
        'Veli Ekle',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryCoach,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openAddParentDialog(BuildContext context) async {
    final credentials = await showDialog<ParentCredentialsEntity>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider(
        create: (_) => ParentSignupCubit(),
        child: AddParentDialog(
          coachId: student.coachId,
          studentId: student.uid,
        ),
      ),
    );
    if (credentials != null && context.mounted) {
      context.read<CurrentStudentCubit>().setStudent(
        student.copyWith(parentId: credentials.parentUid, hasParent: true),
      );
      await ParentCredentialsDialog.show(context, credentials: credentials);
    }
  }
}

class _SetNewPasswordButton extends StatelessWidget {
  const _SetNewPasswordButton({required this.userId, required this.label});

  final String userId;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _openPasswordDialog(context),
      icon: const Icon(Icons.lock_reset, color: AppColors.primaryCoach),
      label: Text(
        label,
        style: const TextStyle(color: AppColors.primaryCoach, fontSize: 16),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primaryCoach),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openPasswordDialog(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final newPassword = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SetPasswordDialog(
        title: label,
        formKey: formKey,
        controller: controller,
      ),
    );

    if (newPassword == null || newPassword.isEmpty || !context.mounted) return;

    final result = await LoadingOverlay.run(
      context,
      sl<UpdateUserPasswordUseCase>().call(
        params: UpdateUserPasswordParams(
          userId: userId,
          newPassword: newPassword,
        ),
      ),
    );

    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      ),
      (_) => _showNewPasswordInfoDialog(context, newPassword),
    );
  }

  static Future<void> _showNewPasswordInfoDialog(BuildContext context, String newPassword) async {
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
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    height: 1.4,
                  ),
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
              style: TextStyle(
                color: AppColors.primaryCoach,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetPasswordDialog extends StatefulWidget {
  const _SetPasswordDialog({
    required this.title,
    required this.formKey,
    required this.controller,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;

  @override
  State<_SetPasswordDialog> createState() => _SetPasswordDialogState();
}

class _SetPasswordDialogState extends State<_SetPasswordDialog> {
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
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCoach,
          ),
          child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _DeleteStudentButton extends StatelessWidget {
  const _DeleteStudentButton({required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _confirmAndDelete(context),
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      label: const Text(
        'Öğrenciyi Sil',
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondBackground,
        title: const Text(
          'Öğrenciyi Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          student.hasParent
              ? 'Bu öğrenci ve veli hesabı kalıcı olarak silinecek. Emin misiniz?'
              : 'Bu öğrenci kalıcı olarak silinecek. Emin misiniz?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await LoadingOverlay.run(
      context,
      sl<DeleteStudentUseCase>().call(params: student.uid),
    );
    if (!context.mounted) return;

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      },
      (_) {
        context.read<CurrentStudentCubit>().clearStudent();
        Navigator.of(context).pop(true);
      },
    );
  }
}
