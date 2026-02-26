import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/presentation/coach/home/bloc/home_cubit.dart';

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
      return 'Yapıldı'; // öğrenci yaptı, koç onayı bekliyor
    case HomeworkSubmissionStatus.approved:
      return 'Tamamlandı ve onaylandı';
    case HomeworkSubmissionStatus.missing:
      return 'Eksik';
    case HomeworkSubmissionStatus.notDone:
      return 'Yapılmadı';
  }
}

Color _statusColor(HomeworkSubmissionStatus s) {
  switch (s) {
    case HomeworkSubmissionStatus.approved:
      return Colors.green;
    case HomeworkSubmissionStatus.completedByStudent:
      return Colors.blue; // öğrenci yaptı - mavi
    case HomeworkSubmissionStatus.missing:
      return Colors.orange; // Eksik - turuncu
    case HomeworkSubmissionStatus.notDone:
      return Colors.red;
    case HomeworkSubmissionStatus.pending:
      return Colors.grey;
  }
}

/// Ödeve özgü detay kartı: sadece ödev bilgisi, durum ve öğrenci yüklemeleri. Düzenleme / silme / ödev ekle yok.
class HomeworkDetailSheet extends StatelessWidget {
  const HomeworkDetailSheet({
    super.key,
    required this.item,
    this.onStatusChanged,
  });

  final CompletedHomeworkItem item;
  /// Ödevler sayfasından açıldığında kullanılır. Tamamlandığında takvim güncellenir, sonra sheet kapanır.
  final Future<void> Function(String homeworkId, String studentId, HomeworkSubmissionStatus status)? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final h = item.homework;
    final s = item.submission;
    final date = h.endDate;
    final courseLabel = h.courseName?.isNotEmpty == true
        ? h.courseName!
        : (h.courseId?.isNotEmpty == true ? h.courseId! : 'Ödev');
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
                  if (h.topicNames.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      h.topicNames.join(' • '),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
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
                  if (h.fileUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Eklenen kaynaklar (görsel / PDF)',
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: h.fileUrls.map((url) => _TeacherResourceTile(url: url)).toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _statusColor(s.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Durum: ${_statusLabel(s.status)}',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
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
                    children: [
                      Expanded(child: _StatusButton(
                        label: 'Yapılan ödev',
                        color: Colors.blue,
                        isSelected: s.status == HomeworkSubmissionStatus.completedByStudent,
                        onTap: () => _setStatus(context, HomeworkSubmissionStatus.completedByStudent),
                      )),
                      const SizedBox(width: 6),
                      Expanded(child: _StatusButton(
                        label: 'Tamamlandı',
                        color: Colors.green,
                        isSelected: s.status == HomeworkSubmissionStatus.approved,
                        onTap: () => _setStatus(context, HomeworkSubmissionStatus.approved),
                      )),
                      const SizedBox(width: 6),
                      Expanded(child: _StatusButton(
                        label: 'Eksik',
                        color: Colors.orange,
                        isSelected: s.status == HomeworkSubmissionStatus.missing,
                        onTap: () => _setStatus(context, HomeworkSubmissionStatus.missing),
                      )),
                      const SizedBox(width: 6),
                      Expanded(child: _StatusButton(
                        label: 'Yapılmadı',
                        color: Colors.red,
                        isSelected: s.status == HomeworkSubmissionStatus.notDone,
                        onTap: () => _setStatus(context, HomeworkSubmissionStatus.notDone),
                      )),
                      const SizedBox(width: 6),
                      Expanded(child: _StatusButton(
                        label: 'Sıfırla',
                        color: Colors.grey,
                        isSelected: s.status == HomeworkSubmissionStatus.pending,
                        onTap: () => _setStatus(context, HomeworkSubmissionStatus.pending),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setStatus(BuildContext context, HomeworkSubmissionStatus status) async {
    if (onStatusChanged != null) {
      await onStatusChanged!(item.homework.id, item.submission.studentId, status);
    } else {
      await context.read<HomeCubit>().setSubmissionStatus(
            item.homework.id,
            item.submission.studentId,
            status,
          );
    }
    if (context.mounted) Navigator.pop(context);
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

}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
          child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
            boxShadow: isSelected
                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 0)]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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

/// Öğretmenin eklediği kaynak: görsel önizleme + tam ekran veya PDF/dosya için tarayıcıda aç.
class _TeacherResourceTile extends StatelessWidget {
  const _TeacherResourceTile({required this.url});

  final String url;

  static bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.jpg') || lower.contains('.jpeg') ||
        lower.contains('.png') || lower.contains('.gif') || lower.contains('.webp');
  }

  static bool _isPdfUrl(String url) {
    return url.toLowerCase().contains('.pdf');
  }

  Future<void> _openInBrowser(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dosya açılamadı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isImageUrl(url)) {
      return _Thumbnail(
        url: url,
        onTap: () => HomeworkDetailSheet._showFullScreenImage(context, url),
      );
    }
    return Material(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => _openInBrowser(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isPdfUrl(url) ? Icons.picture_as_pdf : Icons.insert_drive_file,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                _isPdfUrl(url) ? 'PDF' : 'Dosya',
                style: const TextStyle(color: Colors.white, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
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
