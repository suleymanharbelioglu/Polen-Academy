import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/presentation/student/my_agenda/bloc/st_my_agenda_cubit.dart';
import 'package:polen_academy/presentation/student/my_agenda/bloc/st_my_agenda_state.dart';
import 'package:polen_academy/presentation/student/my_agenda/widget/st_session_card_read_only.dart';

const List<String> _monthNames = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
];

/// Öğrenci gün detayı: sadece seans listesi, seans ekleme/düzenleme/silme yok.
class StAgendaDaySheet extends StatelessWidget {
  const StAgendaDaySheet({
    super.key,
    required this.date,
  });

  final DateTime date;

  static String _formatDate(DateTime d) {
    return '${d.day} ${_monthNames[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StMyAgendaCubit, StMyAgendaState>(
      builder: (context, state) {
        final sessions = state.sessionsOn(date);
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              const Text(
                'Seanslar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              sessions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Seans yok.',
                          style: TextStyle(color: Colors.white54, fontSize: 15),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sessions.length,
                      itemBuilder: (context, i) => StSessionCardReadOnly(
                        session: sessions[i],
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
