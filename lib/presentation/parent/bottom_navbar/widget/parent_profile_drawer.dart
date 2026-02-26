import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/auth/repository/auth.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/auth/page/welcome.dart';
import 'package:polen_academy/presentation/parent/bloc/parent_student_cubit.dart';
import 'package:polen_academy/service_locator.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Veli için sol drawer: ad soyad, rol, "Velisi olduğu öğrenci: ..."; Kullanım Koşulları, Gizlilik, Hesabımı Sil.
class ParentProfileDrawer extends StatelessWidget {
  const ParentProfileDrawer({super.key});

  static const String _termsUrl = 'https://polenacademy.com/kullanim-kosullari';
  static const String _privacyUrl = 'https://polenacademy.com/gizlilik-sozlesmesi';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondBackground,
        title: const Text('Hesabı Sil', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Hesabınız kalıcı olarak kaldırılacak. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Evet, hesabımı sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    LoadingOverlay.show(context);
    String? errorMessage;
    final deleteResult = await sl<AuthFirebaseService>().deleteCurrentUserAccount();
    deleteResult.fold((e) => errorMessage = e, (_) {});
    if (errorMessage == null) {
      await sl<AuthRepository>().signOut();
    }
    if (!context.mounted) return;
    LoadingOverlay.hide(context);
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!), backgroundColor: Colors.red),
      );
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pop();
    AppNavigator.pushAndRemove(context, const WelcomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: AppColors.secondBackground,
      child: SafeArea(
        child: FutureBuilder<Map<String, String>?>(
          future: sl<AuthFirebaseService>().getCurrentUserDisplayInfo(),
          builder: (context, snapshot) {
            final info = snapshot.data;
            final firstName = info?['firstName'] ?? '';
            final lastName = info?['lastName'] ?? '';
            final fullName =
                [firstName, lastName].where((s) => s.isNotEmpty).join(' ').trim();

            return BlocBuilder<ParentStudentCubit, StudentEntity?>(
              builder: (context, student) {
                final studentLabel = student != null
                    ? [student.studentName, student.studentSurname]
                        .where((s) => s.isNotEmpty)
                        .join(' ')
                        .trim()
                    : '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primaryParent)),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName.isNotEmpty ? fullName : 'Veli',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Veli',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryParent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (studentLabel.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Velisi olduğu öğrenci: $studentLabel',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.description_outlined,
                            color: Colors.white70),
                        title: const Text(
                          'Kullanım Koşulları',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        onTap: () => _openUrl(_termsUrl),
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined,
                            color: Colors.white70),
                        title: const Text(
                          'Gizlilik Sözleşmesi',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        onTap: () => _openUrl(_privacyUrl),
                      ),
                    ],
                    const Spacer(),
                    const Divider(color: Colors.white24, height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever,
                          color: Colors.redAccent),
                      title: const Text(
                        'Hesabımı Sil',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      onTap: () => _deleteAccount(context),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Center(
                        child: Text(
                          'Polen Academy',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
