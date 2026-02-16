import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/domain/session/usecases/create_session.dart';
import 'package:polen_academy/domain/session/usecases/update_session.dart';
import 'package:polen_academy/service_locator.dart';

const List<String> _timeSlots = [
  '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
  '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
  '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
  '20:00', '20:30', '21:00', '21:30', '22:00',
];

const List<String> _noteChipLabels = [
  'Öğrenciyle tanışma',
  'Genel durum görüşmesi',
  'Hedeflerin gözden geçirilmesi',
  'Geçen haftanın ödev kontrolü',
  'Yeni hafta ödevlendirmesi',
  'Haftanın değerlendirilmesi',
  'Motivasyon görüşmesi',
  'Deneme analizi',
  'Sınav kaygısı üzerine rehberlik',
];

class PlanSessionDialog extends StatefulWidget {
  const PlanSessionDialog({
    super.key,
    required this.coachId,
    required this.initialDate,
    this.initialSession,
    required this.students,
  });

  final String coachId;
  final DateTime initialDate;
  final SessionEntity? initialSession;
  final List<StudentEntity> students;

  @override
  State<PlanSessionDialog> createState() => _PlanSessionDialogState();
}

class _PlanSessionDialogState extends State<PlanSessionDialog> {
  late String? _studentId;
  late DateTime _date;
  late String _startTime;
  late String? _endTime;
  late bool _hasEndTime;
  late bool _isWeeklyRecurring;
  late List<String> _selectedChips;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final s = widget.initialSession;
    _studentId = s?.studentId;
    _date = s?.date ?? widget.initialDate;
    _startTime = s?.startTime ?? '09:00';
    _hasEndTime = (s?.endTime ?? '').isNotEmpty;
    _endTime = _hasEndTime ? (s?.endTime ?? '09:30') : null;
    _isWeeklyRecurring = s?.isWeeklyRecurring ?? false;
    _selectedChips = s?.noteChips ?? [];
    _noteController = TextEditingController(text: s?.noteText ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialSession != null;

    return AlertDialog(
      backgroundColor: AppColors.secondBackground,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isEdit ? 'Seansı Düzenle' : 'Yeni Seans Planla',
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Öğrenci', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _studentId,
                dropdownColor: AppColors.secondBackground,
                decoration: _inputDecoration(),
                style: const TextStyle(color: Colors.white),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Bir öğrenci seçin', style: TextStyle(color: Colors.white70))),
                  ...widget.students.map((e) => DropdownMenuItem(
                        value: e.uid,
                        child: Text('${e.studentName} ${e.studentSurname}', style: const TextStyle(color: Colors.white)),
                      )),
                ],
                onChanged: (v) => setState(() => _studentId = v),
              ),
              const SizedBox(height: 16),
              const Text('Tarih', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.white70),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 16),
              const Text('Başlangıç', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _startTime,
                dropdownColor: AppColors.secondBackground,
                decoration: _inputDecoration(),
                style: const TextStyle(color: Colors.white),
                items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: (v) => setState(() => _startTime = v ?? _startTime),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Bitiş saati belirle', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(width: 8),
                  Switch(
                    value: _hasEndTime,
                    onChanged: (v) => setState(() {
                      _hasEndTime = v;
                      if (!v) _endTime = null;
                      else {
                        final i = _timeSlots.indexOf(_startTime);
                        _endTime = (i >= 0 && i < _timeSlots.length - 1)
                            ? _timeSlots[i + 1]
                            : '09:30';
                      }
                    }),
                  ),
                ],
              ),
              if (_hasEndTime) ...[
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _endTime,
                  dropdownColor: AppColors.secondBackground,
                  decoration: _inputDecoration(),
                  style: const TextStyle(color: Colors.white),
                  items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (v) => setState(() => _endTime = v),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _isWeeklyRecurring,
                    onChanged: (v) => setState(() => _isWeeklyRecurring = v ?? false),
                    fillColor: WidgetStateProperty.all(AppColors.primaryCoach),
                  ),
                  const Text('Haftalık Tekrarla', style: TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Seans Notları', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _noteChipLabels.map((label) {
                  final selected = _selectedChips.contains(label);
                  return FilterChip(
                    label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontSize: 12)),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) _selectedChips = [..._selectedChips, label];
                        else _selectedChips = _selectedChips.where((c) => c != label).toList();
                      });
                    },
                    backgroundColor: AppColors.secondBackground,
                    selectedColor: AppColors.primaryCoach,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration().copyWith(
                  hintText: 'Seansın konusu, hedefleri vb.',
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text(isEdit ? 'Güncelle' : 'Seansı Planla', style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primaryCoach), borderRadius: BorderRadius.circular(8)),
    );
  }

  Future<void> _save() async {
    if (_studentId == null || _studentId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Öğrenci seçin'), backgroundColor: Colors.orange),
      );
      return;
    }
    final student = widget.students.firstWhere((e) => e.uid == _studentId);
    final studentName = '${student.studentName} ${student.studentSurname}';

    final entity = SessionEntity(
      id: widget.initialSession?.id ?? '',
      coachId: widget.coachId,
      studentId: _studentId!,
      studentName: studentName,
      date: _date,
      startTime: _startTime,
      endTime: _hasEndTime ? _endTime : null,
      isWeeklyRecurring: _isWeeklyRecurring,
      noteChips: _selectedChips,
      noteText: _noteController.text.trim(),
      status: widget.initialSession?.status ?? SessionStatus.scheduled,
      createdAt: widget.initialSession?.createdAt ?? DateTime.now(),
    );

    if (widget.initialSession != null) {
      final result = await LoadingOverlay.run(context, sl<UpdateSessionUseCase>().call(params: entity));
      if (context.mounted) {
        result.fold(
          (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e), backgroundColor: Colors.red)),
          (_) => Navigator.pop(context, entity),
        );
      }
    } else {
      final result = await LoadingOverlay.run(context, sl<CreateSessionUseCase>().call(params: entity));
      if (context.mounted) {
        result.fold(
          (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e), backgroundColor: Colors.red)),
          (created) => Navigator.pop(context, created),
        );
      }
    }
  }
}
