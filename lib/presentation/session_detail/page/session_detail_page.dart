import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/session/entity/session_entity.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';
import 'package:polen_academy/presentation/session_detail/bloc/session_detail_cubit.dart';
import 'package:polen_academy/presentation/session_detail/bloc/session_detail_state.dart';
import 'package:polen_academy/presentation/session_detail/widget/session_day_sheet.dart';
import 'package:polen_academy/presentation/session_detail/widget/session_detail_card.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SessionDetailCubit()..load(widget.student),
      child: BlocBuilder<SessionDetailCubit, SessionDetailState>(
        builder: (context, state) {
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
                    value: state.rangeFilter,
                    dropdownColor: AppColors.secondBackground,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: (v) {
                      if (v != null) {
                        context.read<SessionDetailCubit>().setRangeFilter(v);
                      }
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
            bottomNavigationBar: state.loading || state.error != null
                ? null
                : Container(
                    color: AppColors.secondBackground,
                    child: SafeArea(
                      child: ListenableBuilder(
                        listenable: _tabController,
                        builder: (context, _) => SizedBox(
                          height: 64,
                          child: Row(
                            children: [
                              _SessionNavItem(
                                label: 'Yapılan',
                                count: state.completedCount,
                                selected: _tabController.index == 0,
                                onTap: () => _tabController.animateTo(0),
                                color: const Color(0xFF4CAF50),
                              ),
                              _SessionNavItem(
                                label: 'Yapılmayan',
                                count: state.notDoneCount,
                                selected: _tabController.index == 1,
                                onTap: () => _tabController.animateTo(1),
                                color: const Color(0xFFE53935),
                              ),
                              _SessionNavItem(
                                label: 'Gelecek',
                                count: state.futureCount,
                                selected: _tabController.index == 2,
                                onTap: () => _tabController.animateTo(2),
                                color: const Color(0xFF42A5F5),
                              ),
                              _SessionNavItem(
                                label: 'Tümü',
                                count: state.sessions.length,
                                selected: _tabController.index == 3,
                                onTap: () => _tabController.animateTo(3),
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            body: state.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryCoach,
                    ),
                  )
                : state.error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _SessionList(
                            sessions: state.completedSessions,
                            coachId: widget.student.coachId,
                            onRefresh: () =>
                                context.read<SessionDetailCubit>().load(widget.student),
                          ),
                          _SessionList(
                            sessions: state.notDoneSessions,
                            coachId: widget.student.coachId,
                            onRefresh: () =>
                                context.read<SessionDetailCubit>().load(widget.student),
                          ),
                          _SessionList(
                            sessions: state.futureSessions,
                            coachId: widget.student.coachId,
                            onRefresh: () =>
                                context.read<SessionDetailCubit>().load(widget.student),
                          ),
                          _SessionList(
                            sessions: state.sessions,
                            coachId: widget.student.coachId,
                            onRefresh: () =>
                                context.read<SessionDetailCubit>().load(widget.student),
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }
}

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
  const _SessionList({
    required this.sessions,
    required this.coachId,
    required this.onRefresh,
  });

  final List<SessionEntity> sessions;
  final String coachId;
  final VoidCallback onRefresh;

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
      itemBuilder: (context, index) {
        final session = sessions[index];
        return InkWell(
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => SessionDaySheet(
                coachId: coachId,
                date: session.date,
                onRefresh: onRefresh,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: SessionDetailCard(session: session),
        );
      },
    );
  }
}
