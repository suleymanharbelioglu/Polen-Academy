import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/usecases/add_uploaded_url_to_submission.dart';
import 'package:polen_academy/domain/homework/usecases/set_homework_submission_status.dart';
import 'package:polen_academy/domain/homework/usecases/upload_homework_file.dart';
import 'package:polen_academy/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';

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

Color _statusColor(HomeworkSubmissionStatus s) {
  switch (s) {
    case HomeworkSubmissionStatus.approved:
      return Colors.green;
    case HomeworkSubmissionStatus.completedByStudent:
      return Colors.orange;
    case HomeworkSubmissionStatus.missing:
      return Colors.amber;
    case HomeworkSubmissionStatus.notDone:
      return Colors.red;
    case HomeworkSubmissionStatus.pending:
      return Colors.grey;
  }
}

/// Öğrenci için ödev detayı: koçla aynı içerik; altta "Resim ekle" ve "Yaptım olarak işaretle" butonları.
class StHomeworkDetailSheet extends StatefulWidget {
  const StHomeworkDetailSheet({
    super.key,
    required this.homework,
    required this.studentId,
    this.submission,
    required this.onUpdated,
  });

  final HomeworkEntity homework;
  final String studentId;
  final HomeworkSubmissionEntity? submission;
  final VoidCallback onUpdated;

  @override
  State<StHomeworkDetailSheet> createState() => _StHomeworkDetailSheetState();
}

class _StHomeworkDetailSheetState extends State<StHomeworkDetailSheet> {
  HomeworkSubmissionEntity? _submission;
  bool _addingImage = false;
  bool _markingDone = false;

  @override
  void initState() {
    super.initState();
    _submission = widget.submission;
  }

  @override
  void didUpdateWidget(StHomeworkDetailSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.submission != oldWidget.submission) _submission = widget.submission;
  }

  HomeworkSubmissionEntity get _s {
    return _submission ??
        HomeworkSubmissionEntity(
          id: '${widget.homework.id}_${widget.studentId}',
          homeworkId: widget.homework.id,
          studentId: widget.studentId,
          status: HomeworkSubmissionStatus.pending,
          uploadedUrls: const [],
          completedAt: null,
          updatedAt: DateTime.now(),
        );
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (picked == null || picked.files.isEmpty) return;
    final path = picked.files.single.path;
    if (path == null || path.isEmpty) return;
    setState(() => _addingImage = true);
    final uploadResult = await sl<UploadHomeworkFileUseCase>().call(
      filePath: path,
      studentId: widget.studentId,
    );
    if (!mounted) return;
    uploadResult.fold(
      (err) {
        setState(() => _addingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      },
      (url) async {
        final addResult = await sl<AddUploadedUrlToSubmissionUseCase>().call(
          params: AddUploadedUrlToSubmissionParams(
            homeworkId: widget.homework.id,
            studentId: widget.studentId,
            uploadedUrl: url,
          ),
        );
        if (!mounted) return;
        setState(() => _addingImage = false);
        addResult.fold(
          (err) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err))),
          (_) {
            widget.onUpdated();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _markAsDone() async {
    setState(() => _markingDone = true);
    final result = await sl<SetHomeworkSubmissionStatusUseCase>().call(
      params: SetHomeworkSubmissionStatusParams(
        homeworkId: widget.homework.id,
        studentId: widget.studentId,
        status: HomeworkSubmissionStatus.completedByStudent,
      ),
    );
    if (!mounted) return;
    setState(() => _markingDone = false);
    result.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err))),
      (_) {
        widget.onUpdated();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.homework;
    final s = _s;
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
                    style: const TextStyle(color: AppColors.primaryStudent, fontSize: 14, fontWeight: FontWeight.w600),
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
                          child: _ClickableLink(url: url),
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
                      Expanded(
                        child: _ActionButton(
                          label: 'Resim ekle',
                          icon: Icons.add_photo_alternate,
                          color: AppColors.primaryStudent,
                          loading: _addingImage,
                          onTap: _pickAndUploadImage,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          label: 'Yaptım olarak işaretle',
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                          loading: _markingDone,
                          onTap: _markAsDone,
                        ),
                      ),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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

class _TeacherResourceTile extends StatelessWidget {
  const _TeacherResourceTile({required this.url});

  final String url;

  static bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.jpg') || lower.contains('.jpeg') ||
        lower.contains('.png') || lower.contains('.gif') || lower.contains('.webp');
  }

  static bool _isPdfUrl(String url) => url.toLowerCase().contains('.pdf');

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
        onTap: () => _StHomeworkDetailSheetState._showFullScreenImage(context, url),
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

class _ClickableLink extends StatelessWidget {
  const _ClickableLink({required this.url});

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
            color: AppColors.primaryStudent,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
