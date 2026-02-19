import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/homeworks/bloc/add_homework_cubit.dart';
import 'package:polen_academy/presentation/coach/homeworks/bloc/add_homework_state.dart';

class AddHomeworkPage extends StatelessWidget {
  const AddHomeworkPage({
    super.key,
    required this.student,
    required this.initialDate,
    required this.coachId,
  });

  final StudentEntity student;
  final DateTime initialDate;
  final String coachId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddHomeworkCubit(
        student: student,
        initialDate: initialDate,
        coachId: coachId,
      ),
      child: _AddHomeworkView(
        studentName: '${student.studentName} ${student.studentSurname}',
      ),
    );
  }
}

class _AddHomeworkView extends StatefulWidget {
  const _AddHomeworkView({required this.studentName});

  final String studentName;

  @override
  State<_AddHomeworkView> createState() => _AddHomeworkViewState();
}

class _AddHomeworkViewState extends State<_AddHomeworkView> {
  bool _overlayVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddHomeworkCubit, AddHomeworkState>(
      listener: (context, state) {
        if (state.loading && !_overlayVisible) {
          LoadingOverlay.show(context);
          setState(() => _overlayVisible = true);
        } else if (!state.loading && _overlayVisible) {
          LoadingOverlay.hide(context);
          setState(() => _overlayVisible = false);
        }
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryCoach,
          title: Text(
            'Ödev Ekle - ${widget.studentName}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<AddHomeworkCubit, AddHomeworkState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTypeDropdown(context, state),
                  const SizedBox(height: 16),
                  _buildEndDateDisplay(state.endDate),
                  const SizedBox(height: 16),
                  _buildDescription(context, state),
                  const SizedBox(height: 16),
                  _buildCourseDropdown(context, state),
                  if (state.type == HomeworkType.topicBased && state.courseId != null) ...[
                    const SizedBox(height: 12),
                    _buildTopicList(context, state),
                    const SizedBox(height: 16),
                    _buildGoalSection(context, state),
                  ],
                  const SizedBox(height: 16),
                  _buildLinkSection(context, state),
                  const SizedBox(height: 16),
                  _buildFileSection(context, state),
                  const SizedBox(height: 24),
                  _buildActions(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypeDropdown(BuildContext context, AddHomeworkState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ödev Tipi',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.secondBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<HomeworkType>(
              value: state.type,
              isExpanded: true,
              dropdownColor: AppColors.background,
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(
                  value: HomeworkType.topicBased,
                  child: Text(
                    'Ödev (Konu Seçimli)',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: HomeworkType.freeText,
                  child: Text(
                    'Serbest Metin',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              onChanged: (v) => v != null
                  ? context.read<AddHomeworkCubit>().setType(v)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndDateDisplay(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 20, color: AppColors.primaryCoach),
          const SizedBox(width: 12),
          Text(
            'Bitiş Tarihi: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, AddHomeworkState state) {
    return TextField(
      onChanged: (v) => context.read<AddHomeworkCubit>().setDescription(v),
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Açıklama',
        hintText: 'Örn: ders kitabındaki konuyu 2 kere oku',
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.secondBackground,
      ),
    );
  }

  Widget _buildCourseDropdown(BuildContext context, AddHomeworkState state) {
    final tree = state.curriculumTree;
    if (tree == null || tree.courses.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ders',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.secondBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.courseId,
              isExpanded: true,
              dropdownColor: AppColors.background,
              style: const TextStyle(color: Colors.white),
              hint: const Text(
                'Ders seçin',
                style: TextStyle(color: Colors.white54),
              ),
              items: [
                ...tree.courses.map(
                  (c) => DropdownMenuItem(
                    value: c.course.id,
                    child: Text(
                      c.course.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
              onChanged: (v) => context.read<AddHomeworkCubit>().setCourseId(v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicList(BuildContext context, AddHomeworkState state) {
    final tree = state.curriculumTree;
    if (tree == null) return const SizedBox.shrink();
    CourseWithUnits? course;
    for (final c in tree.courses) {
      if (c.course.id == state.courseId) {
        course = c;
        break;
      }
    }
    if (course == null) return const SizedBox.shrink();
    final topics = <String, String>{};
    for (final u in course.units) {
      for (final t in u.topics) {
        topics[t.id] = '${u.unit.name} / ${t.name}';
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Konu(lar)',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ...topics.entries.map((e) {
          final selected = state.topicIds.contains(e.key);
          return CheckboxListTile(
            value: selected,
            onChanged: (_) =>
                context.read<AddHomeworkCubit>().toggleTopic(e.key),
            title: Text(
              e.value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            activeColor: AppColors.primaryCoach,
            controlAffinity: ListTileControlAffinity.leading,
          );
        }),
      ],
    );
  }

  Widget _buildGoalSection(BuildContext context, AddHomeworkState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bu Ödevin Hedefi Nedir?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ödev onaylandığında, öğrencinin Hedefler tablosundaki hangi ilerlemesinin otomatik güncelleneceğini seçin.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: state.goalKonuStudied,
          onChanged: (v) =>
              context.read<AddHomeworkCubit>().setGoalKonuStudied(v ?? true),
          title: const Text(
            'Konu Çalışması',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          activeColor: AppColors.primaryCoach,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          value: state.goalRevisionDone,
          onChanged: (v) =>
              context.read<AddHomeworkCubit>().setGoalRevisionDone(v ?? true),
          title: const Text(
            'Tekrar',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          activeColor: AppColors.primaryCoach,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          value: state.goalResourceSolve,
          onChanged: (v) =>
              context.read<AddHomeworkCubit>().setGoalResourceSolve(v ?? true),
          title: const Text(
            'Kaynak Çöz',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          activeColor: AppColors.primaryCoach,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildLinkSection(BuildContext context, AddHomeworkState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () => _showLinkDialog(context),
          icon: const Icon(Icons.link, color: Colors.white, size: 20),
          label: const Text('Link ekle', style: TextStyle(color: Colors.white)),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.primaryCoach,
            side: BorderSide.none,
          ),
        ),
        if (state.links.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...state.links.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: _ClickableLink(url: e.value),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                      onPressed: () => context.read<AddHomeworkCubit>().removeLink(e.key),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Future<void> _showLinkDialog(BuildContext context) async {
    final controller = TextEditingController();
    final link = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondBackground,
        title: const Text('Link gir', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'https://...',
            hintStyle: const TextStyle(color: Colors.white38),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onSubmitted: (v) =>
              Navigator.of(ctx).pop(v.trim().isEmpty ? null : v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(
              controller.text.trim().isEmpty ? null : controller.text.trim(),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryCoach,
            ),
            child: const Text('Tamam', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (link != null && context.mounted) {
      context.read<AddHomeworkCubit>().addLink(link);
    }
  }

  Widget _buildFileSection(
    BuildContext context,
    AddHomeworkState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dosya Ekle (Resim veya PDF)',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickAndUploadFiles(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.secondBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white24,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: Colors.white54,
                ),
                const SizedBox(height: 8),
                Text(
                  'Yüklemek için tıklayın veya sürükleyin',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'PNG, JPG veya PDF (Maks. 5MB)',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        if (state.fileUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...state.fileUrls.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _openFileUrl(e.value),
                      child: Row(
                        children: [
                          Icon(
                            e.value.toLowerCase().contains('.pdf')
                                ? Icons.picture_as_pdf
                                : Icons.image,
                            size: 20,
                            color: AppColors.primaryCoach,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dosya ${e.key + 1}',
                              style: const TextStyle(
                                color: AppColors.primaryCoach,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: () =>
                        context.read<AddHomeworkCubit>().removeFileUrl(e.key),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Future<void> _pickAndUploadFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty || !context.mounted) return;
    final paths = result.files
        .where((f) => f.path != null && f.path!.isNotEmpty)
        .map((f) => f.path!)
        .toList();
    if (paths.isEmpty) return;
    final cubit = context.read<AddHomeworkCubit>();
    await cubit.uploadFilesWithLoading(paths);
    if (!context.mounted) return;
    if (cubit.state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } else if (paths.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dosyalar eklendi'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _openFileUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white54,
              side: const BorderSide(color: Colors.white24),
            ),
            child: const Text('İptal'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final success = await context.read<AddHomeworkCubit>().submit();
              if (success && context.mounted) Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCoach,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ödevi Ekle'),
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 4),
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
