import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/user/repository/user_repository.dart';
import 'package:polen_academy/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Öğrenci için sol drawer: ad soyad, rol, "Velisi: ..."; Kullanım Koşulları, Gizlilik.
class StudentProfileDrawer extends StatelessWidget {
  const StudentProfileDrawer({super.key});

  static const String _termsUrl = 'https://docs.google.com/document/d/1MImi4_L1mk8YqLaCojRDflZWvDco4mRgbzQx1DXH5yo/view';
  static const String _privacyUrl = 'https://docs.google.com/document/d/1GwrRMJKr-pEs0apxG67fCIr76VLE-KZBecOleykP6cQ/view';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
            final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ').trim();

            return FutureBuilder<String>(
              future: _parentLabel(),
              builder: (context, parentSnapshot) {
                final parentLabel = parentSnapshot.data ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                            child: CircularProgressIndicator(color: AppColors.primaryStudent)),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName.isNotEmpty ? fullName : 'Öğrenci',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Öğrenci',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryStudent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (parentLabel.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Velisi: $parentLabel',
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
                        leading: const Icon(Icons.description_outlined, color: Colors.white70),
                        title: const Text(
                          'Kullanım Koşulları',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        onTap: () => _openUrl(_termsUrl),
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined, color: Colors.white70),
                        title: const Text(
                          'Gizlilik Sözleşmesi',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        onTap: () => _openUrl(_privacyUrl),
                      ),
                    ],
                    const Spacer(),
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

  Future<String> _parentLabel() async {
    final uid = sl<AuthFirebaseService>().getCurrentUserUid();
    if (uid == null || uid.isEmpty) return '';
    final studentResult = await sl<UserRepository>().getStudentByUid(uid);
    final student = studentResult.fold((_) => null, (s) => s);
    final parentId = student?.parentId ?? '';
    if (parentId.isEmpty) return '';
    return sl<AuthFirebaseService>().getParentDisplayName(parentId);
  }
}
