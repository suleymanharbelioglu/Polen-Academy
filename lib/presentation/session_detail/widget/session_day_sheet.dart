import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_date.dart';
import 'package:polen_academy/presentation/coach/my_agenda/widget/session_card.dart';
import 'package:polen_academy/service_locator.dart';

const List<String> _monthNames = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

/// Seans detay sayfasında karta tıklanınca açılır: o günün seanslarını listeler, Ajandam’daki gibi onayla/iptal/sil yapılabilir.
class SessionDaySheet extends StatefulWidget {
  const SessionDaySheet({
    super.key,
    required this.coachId,
    required this.date,
    this.onRefresh,
  });

  final String coachId;
  final DateTime date;
  final VoidCallback? onRefresh;

  static String _formatDate(DateTime d) {
    return '${d.day} ${_monthNames[d.month - 1]} ${d.year}';
  }

  static bool _canMarkSessionStatus(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return !d.isAfter(today);
  }

  @override
  State<SessionDaySheet> createState() => _SessionDaySheetState();
}

class _SessionDaySheetState extends State<SessionDaySheet> {
  List<SessionEntity> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await sl<GetSessionsByDateUseCase>().call(
      params: GetSessionsByDateParams(coachId: widget.coachId, date: widget.date),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sessions = result.fold((_) => <SessionEntity>[], (list) => list)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  void _onRefresh() {
    _load();
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
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
                SessionDaySheet._formatDate(widget.date),
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
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: AppColors.primaryCoach)),
            )
          else if (_sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Seans yok.',
                  style: TextStyle(color: Colors.white54, fontSize: 15),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sessions.length,
              itemBuilder: (context, i) => SessionCard(
                session: _sessions[i],
                onRefresh: _onRefresh,
                canMarkStatus: SessionDaySheet._canMarkSessionStatus(widget.date),
              ),
            ),
        ],
      ),
    );
  }
}
