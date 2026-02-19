import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/homework/usecases/delete_homework.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/presentation/coach/home/bloc/home_cubit.dart';
import 'package:polen_academy/presentation/coach/homeworks/page/add_homework_page.dart';
import 'package:polen_academy/service_locator.dart';

const List<String> _weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
const List<String> _months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

String _formatDate(DateTime d) {
  return '${d.day} ${_months[d.month - 1]} ${_weekdays[d.weekday - 1]}';
}

String _statusLabel(HomeworkSubmissionStatus s) {
  switch (s) {
    case HomeworkSubmissionStatus.pending:
      return 'Bekliyor';
    case HomeworkSubmissionStatus.completedByStudent:
      return 'Onay Bekliyor';
    case HomeworkSubmissionStatus.approved:
      return 'Tamamlandı';
    case HomeworkSubmissionStatus.missing:
      return 'Eksik';
    case HomeworkSubmissionStatus.notDone:
      return 'Yapılmadı';
  }
}

class HomeworkDetailSheet extends StatelessWidget {
  const HomeworkDetailSheet({
    super.key,
    required this.item,
    this.onStatusChanged,
  });

  final CompletedHomeworkItem item;
  /// Ödevler sayfasından açıldığında kullanılır (HomeCubit yok).
  final void Function(String homeworkId, String studentId, HomeworkSubmissionStatus status)? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final h = item.homework;
    final s = item.submission;
    final date = h.endDate;
    final courseLabel = h.courseId?.isNotEmpty == true ? h.courseId! : 'Ders';
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseLabel,
                    style: const TextStyle(color: AppColors.primaryCoach, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    h.description.isNotEmpty ? h.description : 'Ödev',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  if (h.links.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    ...h.links.map((url) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _ClickableHomeworkLink(url: url),
                        )),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Durum: ${_statusLabel(s.status)}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Öğrenci Yüklemeleri',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (s.uploadedUrls.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Yüklenen görsel yok.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: s.uploadedUrls
                          .map((url) => _Thumbnail(
                                url: url,
                                onTap: () => _showFullScreenImage(context, url),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatusButton(
                              label: 'Tamamlandı',
                              color: Colors.green,
                              onTap: () => _setStatus(context, HomeworkSubmissionStatus.approved),
                            ),
                            _StatusButton(
                              label: 'Eksik',
                              color: Colors.orange,
                              onTap: () => _setStatus(context, HomeworkSubmissionStatus.missing),
                            ),
                            _StatusButton(
                              label: 'Yapılmadı',
                              color: Colors.red,
                              onTap: () => _setStatus(context, HomeworkSubmissionStatus.notDone),
                            ),
                            _StatusButton(
                              label: 'Sıfırla',
                              color: Colors.grey,
                              onTap: () => _setStatus(context, HomeworkSubmissionStatus.pending),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white70, size: 22),
                            onPressed: () => _editHomework(context),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                            onPressed: () => _deleteHomework(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _addHomework(context),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Ödev Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setStatus(BuildContext context, HomeworkSubmissionStatus status) {
    if (onStatusChanged != null) {
      onStatusChanged!(item.homework.id, item.submission.studentId, status);
    } else {
      context.read<HomeCubit>().setSubmissionStatus(
            item.homework.id,
            item.submission.studentId,
            status,
          );
    }
    Navigator.pop(context);
  }

  static void _showFullScreenImage(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white, size: 48),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editHomework(BuildContext context) {
    Navigator.pop(context);
    // TODO: Navigate to edit homework (reuse AddHomeworkPage with initial data if supported)
  }

  Future<void> _deleteHomework(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ödevi Sil'),
        content: const Text('Bu ödevi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final result = await sl<DeleteHomeworkUseCase>().call(params: item.homework.id);
    if (!context.mounted) return;
    result.fold(
      (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e))),
      (_) {
        Navigator.pop(context);
        context.read<HomeCubit>().load();
      },
    );
  }

  void _addHomework(BuildContext context) {
    Navigator.pop(context);
    final students = context.read<HomeCubit>().state.students;
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Öğrenci bulunamadı.')));
      return;
    }
    StudentEntity student = students.first;
    for (final s in students) {
      if (s.uid == item.submission.studentId) {
        student = s;
        break;
      }
    }
    final coachId = sl<AuthFirebaseService>().getCurrentUserUid() ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AddHomeworkPage(
          student: student,
          initialDate: DateTime.now(),
          coachId: coachId,
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url, this.onTap});

  final String url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 80,
          height: 80,
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }
}

class _ClickableHomeworkLink extends StatelessWidget {
  const _ClickableHomeworkLink({required this.url});

  final String url;

  Future<void> _openUrl() async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openUrl,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          url,
          style: const TextStyle(
            color: AppColors.primaryCoach,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
