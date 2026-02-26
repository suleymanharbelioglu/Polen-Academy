import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/session/usecases/get_sessions_by_date_range.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';
import 'package:polen_academy/presentation/session_detail/widget/session_detail_card.dart';
import 'package:polen_academy/service_locator.dart';

class SessionDetailPage extends StatefulWidget {
  const SessionDetailPage({
    super.key,
    required this.student,
  });

  final StudentEntity student;

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StudentDetailRangeFilter _rangeFilter = StudentDetailRangeFilter.lastWeek;
  List<SessionEntity> _allSessions = [];
  bool _loading = true;
  String? _error;

  List<SessionEntity> get _completed =>
      _allSessions.where((s) => s.status == SessionStatus.completed).toList();
  List<SessionEntity> get _notDone =>
      _allSessions.where((s) => s.status == SessionStatus.cancelled).toList();
  List<SessionEntity> get _future {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return _allSessions.where((s) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      return d.isAfter(today) && s.status == SessionStatus.scheduled;
    }).toList();
  }

  static DateTime _rangeStart(
    StudentDetailRangeFilter filter,
    StudentEntity student,
    DateTime end,
  ) {
    final reg = student.registeredAt != null
        ? DateTime(
            student.registeredAt!.year,
            student.registeredAt!.month,
            student.registeredAt!.day,
          )
        : null;
    final DateTime requested;
    switch (filter) {
      case StudentDetailRangeFilter.lastWeek:
        requested = end.subtract(const Duration(days: 7));
        break;
      case StudentDetailRangeFilter.lastMonth:
        requested = end.subtract(const Duration(days: 30));
        break;
      case StudentDetailRangeFilter.all:
        requested = reg ?? end.subtract(const Duration(days: 365));
        break;
    }
    if (reg != null && requested.isBefore(reg)) return reg;
    return requested;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final end = DateTime.now();
    final start = _rangeStart(_rangeFilter, widget.student, end);
    final startNorm = DateTime(start.year, start.month, start.day);
    final endWithFuture = end.add(const Duration(days: 60));

    final result = await sl<GetSessionsByDateRangeUseCase>().call(
      params: GetSessionsByDateRangeParams(
        coachId: widget.student.coachId,
        start: startNorm,
        end: endWithFuture,
      ),
    );

    if (!mounted) return;
    result.fold(
      (e) => setState(() {
        _loading = false;
        _error = e;
        _allSessions = [];
      }),
      (list) => setState(() {
        _loading = false;
        _error = null;
        _allSessions = list
            .where((s) => s.studentId == widget.student.uid)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      }),
    );
  }

  void _setRange(StudentDetailRangeFilter filter) {
    if (_rangeFilter == filter) return;
    setState(() => _rangeFilter = filter);
    _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondBackground,
        foregroundColor: Colors.white,
        title: const Text('Seans Detayları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButton<StudentDetailRangeFilter>(
              value: _rangeFilter,
              dropdownColor: AppColors.secondBackground,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (v) {
                if (v != null) _setRange(v);
              },
              items: const [
                DropdownMenuItem(
                  value: StudentDetailRangeFilter.lastWeek,
                  child: Text('Son Hafta'),
                ),
                DropdownMenuItem(
                  value: StudentDetailRangeFilter.lastMonth,
                  child: Text('Son Ay'),
                ),
                DropdownMenuItem(
                  value: StudentDetailRangeFilter.all,
                  child: Text('Tümü'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _loading || _error != null
          ? null
          : Container(
              color: AppColors.secondBackground,
              child: SafeArea(
                child: ListenableBuilder(
                  listenable: _tabController,
                  builder: (context, _) {
                    return SizedBox(
                      height: 64,
                      child: Row(
                        children: [
                          _SessionNavItem(
                            label: 'Yapılan',
                            count: _completed.length,
                            selected: _tabController.index == 0,
                            onTap: () => _tabController.animateTo(0),
                            color: const Color(0xFF4CAF50),
                          ),
                          _SessionNavItem(
                            label: 'Yapılmayan',
                            count: _notDone.length,
                            selected: _tabController.index == 1,
                            onTap: () => _tabController.animateTo(1),
                            color: const Color(0xFFE53935),
                          ),
                          _SessionNavItem(
                            label: 'Gelecek',
                            count: _future.length,
                            selected: _tabController.index == 2,
                            onTap: () => _tabController.animateTo(2),
                            color: const Color(0xFF42A5F5),
                          ),
                          _SessionNavItem(
                            label: 'Tümü',
                            count: _allSessions.length,
                            selected: _tabController.index == 3,
                            onTap: () => _tabController.animateTo(3),
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryCoach),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _SessionList(sessions: _completed),
                    _SessionList(sessions: _notDone),
                    _SessionList(sessions: _future),
                    _SessionList(sessions: _allSessions),
                  ],
                ),
    );
  }
}

/// Bottom nav: kelime üstte, sayı altta; en altta rengiyle çizgi, seçiliyken belirgin.
class _SessionNavItem extends StatelessWidget {
  const _SessionNavItem({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? color : Colors.white70;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$count',
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: selected ? 3 : 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: selected ? color : color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.sessions});

  final List<SessionEntity> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'Seans bulunamadı',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sessions.length,
      itemBuilder: (context, index) =>
          SessionDetailCard(session: sessions[index]),
    );
  }
}
