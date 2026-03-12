import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/core/network/network_error_helper.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/domain/homework/usecases/set_homework_submission_status.dart';
import 'package:polen_academy/domain/goals/usecases/revert_topic_progress_for_homework.dart';
import 'package:polen_academy/domain/goals/usecases/sync_topic_progress_from_homework.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';
import 'package:polen_academy/presentation/coach/homeworks/widget/homework_detail_sheet.dart';
import 'package:polen_academy/presentation/homework_detail/bloc/homework_detail_cubit.dart';
import 'package:polen_academy/presentation/homework_detail/bloc/homework_detail_state.dart';
import 'package:polen_academy/presentation/homework_detail/widget/homework_detail_card.dart';
import 'package:polen_academy/presentation/student/homeworks/widget/st_homework_detail_sheet.dart';
import 'package:polen_academy/service_locator.dart';

class HomeworkDetailPage extends StatefulWidget {
  const HomeworkDetailPage({
    super.key,
    required this.student,
    this.useStudentDetailSheet = false,
    this.showMarkAsDone = true,
  });

  final StudentEntity student;
  final bool useStudentDetailSheet;
  final bool showMarkAsDone;

  @override
  State<HomeworkDetailPage> createState() => _HomeworkDetailPageState();
}

class _HomeworkDetailPageState extends State<HomeworkDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openDetail(HomeworkEntity homework, HomeworkSubmissionEntity? submission) {
    final student = widget.student;
    final sub = submission ??
        HomeworkSubmissionEntity(
          id: '${homework.id}_${student.uid}',
          homeworkId: homework.id,
          studentId: student.uid,
          status: HomeworkSubmissionStatus.pending,
          uploadedUrls: const [],
          completedAt: null,
          updatedAt: DateTime.now(),
        );
    if (widget.useStudentDetailSheet) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => StHomeworkDetailSheet(
          homework: homework,
          studentId: student.uid,
          submission: sub,
          onUpdated: () => context.read<HomeworkDetailCubit>().load(student),
          showMarkAsDone: widget.showMarkAsDone,
        ),
      );
      return;
    }
    final item = CompletedHomeworkItem(
      homework: homework,
      submission: sub,
      studentName: '${student.studentName} ${student.studentSurname}',
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HomeworkDetailSheet(
        item: item,
        onStatusChanged: (homeworkId, studentId, status) =>
            _setStatus(homeworkId, studentId, status),
      ),
    );
  }

  Future<void> _setStatus(
    String homeworkId,
    String studentId,
    HomeworkSubmissionStatus status,
  ) async {
    final result = await sl<SetHomeworkSubmissionStatusUseCase>().call(
      params: SetHomeworkSubmissionStatusParams(
        homeworkId: homeworkId,
        studentId: studentId,
        status: status,
      ),
    );
    if (!mounted) return;
    result.fold(
      (e) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(NetworkErrorHelper.getUserFriendlyMessage(e))),
      ),
      (_) async {
        if (status == HomeworkSubmissionStatus.pending) {
          await sl<RevertTopicProgressForHomeworkUseCase>().call(
            params: RevertTopicProgressForHomeworkParams(
              homeworkId: homeworkId,
              studentId: studentId,
            ),
          );
        } else {
          await sl<SyncTopicProgressFromHomeworkUseCase>().call(
            params: SyncTopicProgressFromHomeworkParams(
              homeworkId: homeworkId,
              studentId: studentId,
              status: status,
            ),
          );
        }
        if (!mounted) return;
        context.read<HomeworkDetailCubit>().load(widget.student);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeworkDetailCubit()..load(widget.student),
      child: BlocBuilder<HomeworkDetailCubit, HomeworkDetailState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.secondBackground,
              foregroundColor: Colors.white,
              title: const Text('Ödev Detayları'),
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
                      if (v != null) context.read<HomeworkDetailCubit>().setRangeFilter(v);
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
                              _NavItem(
                                label: 'Yapılan',
                                count: state.completedCount,
                                selected: _tabController.index == 0,
                                onTap: () => _tabController.animateTo(0),
                                color: const Color(0xFF4CAF50),
                              ),
                              _NavItem(
                                label: 'Geciken',
                                count: state.overdueCount,
                                selected: _tabController.index == 1,
                                onTap: () => _tabController.animateTo(1),
                                color: const Color(0xFF8D6E63),
                              ),
                              _NavItem(
                                label: 'Eksik',
                                count: state.missingCount,
                                selected: _tabController.index == 2,
                                onTap: () => _tabController.animateTo(2),
                                color: Colors.amber,
                              ),
                              _NavItem(
                                label: 'Yapılmadı',
                                count: state.notDoneCount,
                                selected: _tabController.index == 3,
                                onTap: () => _tabController.animateTo(3),
                                color: Colors.deepOrange.shade300,
                              ),
                              _NavItem(
                                label: 'Tümü',
                                count: state.homeworks.length,
                                selected: _tabController.index == 4,
                                onTap: () => _tabController.animateTo(4),
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
                    child: CircularProgressIndicator(color: AppColors.primaryCoach),
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
                          _HomeworkTab(
                            items: state.completedItems,
                            onTap: (h, _) => _openDetail(
                              h,
                              state.submissionByHomeworkId[h.id],
                            ),
                          ),
                          _HomeworkTab(
                            items: state.overdueItems,
                            onTap: (h, _) => _openDetail(
                              h,
                              state.submissionByHomeworkId[h.id],
                            ),
                          ),
                          _HomeworkTab(
                            items: state.missingItems,
                            onTap: (h, _) => _openDetail(
                              h,
                              state.submissionByHomeworkId[h.id],
                            ),
                          ),
                          _HomeworkTab(
                            items: state.notDoneItems,
                            onTap: (h, _) => _openDetail(
                              h,
                              state.submissionByHomeworkId[h.id],
                            ),
                          ),
                          _HomeworkTab(
                            items: state.allItems,
                            onTap: (h, _) => _openDetail(
                              h,
                              state.submissionByHomeworkId[h.id],
                            ),
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
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

class _HomeworkTab extends StatelessWidget {
  const _HomeworkTab({
    required this.items,
    required this.onTap,
  });

  final List<(HomeworkEntity, HomeworkSubmissionStatus)> items;
  final void Function(HomeworkEntity homework, HomeworkSubmissionStatus status) onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Ödev bulunamadı',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final (homework, displayStatus) = items[index];
        return InkWell(
          onTap: () => onTap(homework, displayStatus),
          borderRadius: BorderRadius.circular(12),
          child: HomeworkDetailCard(
            homework: homework,
            displayStatus: displayStatus,
          ),
        );
      },
    );
  }
}
