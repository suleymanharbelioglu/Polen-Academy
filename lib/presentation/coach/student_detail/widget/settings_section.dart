import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.student,
    required this.onSetPassword,
    required this.onAddParent,
    required this.onConfirmDelete,
  });

  final StudentEntity student;
  final void Function(String userId, String label) onSetPassword;
  final VoidCallback onAddParent;
  final VoidCallback onConfirmDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ayarlar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SettingsTile(
            icon: Icons.lock_reset,
            label: 'Öğrenciye yeni şifre belirle',
            onTap: () => onSetPassword(student.uid, 'Öğrenciye yeni şifre ver'),
          ),
          if (student.hasParent)
            SettingsTile(
              icon: Icons.lock_reset,
              label: 'Veliye yeni şifre belirle',
              onTap: () => onSetPassword(student.parentId, 'Veliye yeni şifre ver'),
            ),
          SettingsTile(
            icon: Icons.delete_outline,
            label: 'Öğrenciyi sil',
            color: Colors.red,
            onTap: onConfirmDelete,
          ),
          if (!student.hasParent) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddParent,
                icon: const Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Veli Ekle',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCoach,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primaryCoach;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54, size: 22),
      onTap: onTap,
    );
  }
}
