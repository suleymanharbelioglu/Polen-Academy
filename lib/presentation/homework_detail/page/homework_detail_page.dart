import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';
import 'package:polen_academy/domain/homework/repository/homework_submission_repository.dart';
import 'package:polen_academy/domain/homework/usecases/get_homeworks_by_student_and_date_range.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/domain/homework/usecases/set_homework_submission_status.dart';
import 'package:polen_academy/domain/goals/usecases/revert_topic_progress_for_homework.dart';
import 'package:polen_academy/domain/goals/usecases/sync_topic_progress_from_homework.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';
import 'package:polen_academy/presentation/coach/homeworks/widget/homework_detail_sheet.dart';
import 'package:polen_academy/presentation/homework_detail/widget/homework_detail_card.dart';
import 'package:polen_academy/service_locator.dart';

class HomeworkDetailPage extends StatefulWidget {
  const HomeworkDetailPage({
    super.key,
    required this.student,
  });

  final StudentEntity student;

  @override
  State<HomeworkDetailPage> createState() => _HomeworkDetailPageState();
}

class _HomeworkDetailPageState extends State<HomeworkDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StudentDetailRangeFilter _rangeFilter = StudentDetailRangeFilter.lastWeek;
  List<HomeworkEntity> _homeworks = [];
  Map<String, HomeworkSubmissionEntity> _submissionByHomeworkId = {};
  bool _loading = true;
  String? _error;

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

  List<HomeworkEntity> get _completed => _homeworks.where((h) {
        final sub = _submissionByHomeworkId[h.id];
        return sub != null && sub.isCompleted;
      }).toList();

  List<HomeworkEntity> get _overdue => _homeworks.where((h) {
        final sub = _submissionByHomeworkId[h.id];
        final endDay = DateTime(h.endDate.year, h.endDate.month, h.endDate.day);
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        return (sub == null || !sub.isCompleted) && endDay.isBefore(today);
      }).toList();

  List<HomeworkEntity> get _missing => _homeworks.where((h) {
        final sub = _submissionByHomeworkId[h.id];
        final endDay = DateTime(h.endDate.year, h.endDate.month, h.endDate.day);
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        if (sub != null && sub.isCompleted) return false;
        if (endDay.isBefore(today)) return false;
        return sub?.status == HomeworkSubmissionStatus.missing ||
            sub?.status == HomeworkSubmissionStatus.pending;
      }).toList();

  List<HomeworkEntity> get _notDone => _homeworks.where((h) {
        final sub = _submissionByHomeworkId[h.id];
        final endDay = DateTime(h.endDate.year, h.endDate.month, h.endDate.day);
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        if (sub != null && sub.isCompleted) return false;
        if (endDay.isBefore(today)) return false;
        return sub?.status == HomeworkSubmissionStatus.notDone;
      }).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadHomeworks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeworks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final end = DateTime.now();
    final start = _rangeStart(_rangeFilter, widget.student, end);
    final startNorm = DateTime(start.year, start.month, start.day);
    final endNorm = DateTime(end.year, end.month, end.day);

    final result = await sl<GetHomeworksByStudentAndDateRangeUseCase>().call(
      params: GetHomeworksByStudentAndDateRangeParams(
        studentId: widget.student.uid,
        start: startNorm,
        end: endNorm,
      ),
    );

    if (!mounted) return;
    result.fold(
      (e) => setState(() {
        _loading = false;
        _error = e;
        _homeworks = [];
        _submissionByHomeworkId = {};
      }),
      (list) async {
        if (list.isEmpty) {
          setState(() {
            _loading = false;
            _homeworks = [];
            _submissionByHomeworkId = {};
          });
          return;
        }
        final ids = list.map((h) => h.id).toList();
        const statuses = [
          HomeworkSubmissionStatus.pending,
          HomeworkSubmissionStatus.completedByStudent,
          HomeworkSubmissionStatus.approved,
          HomeworkSubmissionStatus.missing,
          HomeworkSubmissionStatus.notDone,
        ];
        final subResult = await sl<HomeworkSubmissionRepository>()
            .getByHomeworkIdsAndStatus(ids, statuses);
        final submissionByHomeworkId = <String, HomeworkSubmissionEntity>{};
        subResult.fold((_) {}, (subs) {
          for (final sub in subs) {
            if (sub.studentId == widget.student.uid) {
              submissionByHomeworkId[sub.homeworkId] = sub;
            }
          }
        });
        if (!mounted) return;
        setState(() {
          _loading = false;
          _homeworks = list
            ..sort((a, b) {
              final da = a.assignedDate ?? a.createdAt;
              final db = b.assignedDate ?? b.createdAt;
              return db.compareTo(da);
            });
          _submissionByHomeworkId = submissionByHomeworkId;
        });
      },
    );
  }

  void _setRange(StudentDetailRangeFilter filter) {
    if (_rangeFilter == filter) return;
    setState(() => _rangeFilter = filter);
    _loadHomeworks();
  }

  void _openHomeworkDetail(HomeworkEntity homework) {
    final student = widget.student;
    final sub = _submissionByHomeworkId[homework.id];
    final submission = sub ??
        HomeworkSubmissionEntity(
          id: '${homework.id}_${student.uid}',
          homeworkId: homework.id,
          studentId: student.uid,
          status: HomeworkSubmissionStatus.pending,
          uploadedUrls: const [],
          completedAt: null,
          updatedAt: DateTime.now(),
        );
    final studentName = '${student.studentName} ${student.studentSurname}';
    final item = CompletedHomeworkItem(
      homework: homework,
      submission: submission,
      studentName: studentName,
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HomeworkDetailSheet(
        item: item,
        onStatusChanged: (homeworkId, studentId, status) async {
          await _setStatusFromDetailPage(homeworkId, studentId, status);
        },
      ),
    );
  }

  Future<void> _setStatusFromDetailPage(
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
      (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e))),
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
        _loadHomeworks();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                          _NavItem(
                            label: 'Yapılan',
                            count: _completed.length,
                            selected: _tabController.index == 0,
                            onTap: () => _tabController.animateTo(0),
                            color: const Color(0xFF4CAF50),
                          ),
                          _NavItem(
                            label: 'Geciken',
                            count: _overdue.length,
                            selected: _tabController.index == 1,
                            onTap: () => _tabController.animateTo(1),
                            color: const Color(0xFF8D6E63),
                          ),
                          _NavItem(
                            label: 'Eksik',
                            count: _missing.length,
                            selected: _tabController.index == 2,
                            onTap: () => _tabController.animateTo(2),
                            color: Colors.amber,
                          ),
                          _NavItem(
                            label: 'Yapılmadı',
                            count: _notDone.length,
                            selected: _tabController.index == 3,
                            onTap: () => _tabController.animateTo(3),
                            color: Colors.deepOrange.shade300,
                          ),
                          _NavItem(
                            label: 'Tümü',
                            count: _homeworks.length,
                            selected: _tabController.index == 4,
                            onTap: () => _tabController.animateTo(4),
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
                    _HomeworkList(
                      homeworks: _completed,
                      submissionByHomeworkId: _submissionByHomeworkId,
                      studentId: widget.student.uid,
                      student: widget.student,
                      onHomeworkTap: _openHomeworkDetail,
                    ),
                    _HomeworkList(
                      homeworks: _overdue,
                      submissionByHomeworkId: _submissionByHomeworkId,
                      studentId: widget.student.uid,
                      student: widget.student,
                      onHomeworkTap: _openHomeworkDetail,
                    ),
                    _HomeworkList(
                      homeworks: _missing,
                      submissionByHomeworkId: _submissionByHomeworkId,
                      studentId: widget.student.uid,
                      student: widget.student,
                      onHomeworkTap: _openHomeworkDetail,
                    ),
                    _HomeworkList(
                      homeworks: _notDone,
                      submissionByHomeworkId: _submissionByHomeworkId,
                      studentId: widget.student.uid,
                      student: widget.student,
                      onHomeworkTap: _openHomeworkDetail,
                    ),
                    _HomeworkList(
                      homeworks: _homeworks,
                      submissionByHomeworkId: _submissionByHomeworkId,
                      studentId: widget.student.uid,
                      student: widget.student,
                      onHomeworkTap: _openHomeworkDetail,
                    ),
                  ],
                ),
    );
  }
}

/// Bottom nav: kelime üstte, sayı altta; en altta rengiyle çizgi, seçiliyken belirgin.
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

class _HomeworkList extends StatelessWidget {
  const _HomeworkList({
    required this.homeworks,
    required this.submissionByHomeworkId,
    required this.studentId,
    required this.student,
    required this.onHomeworkTap,
  });

  final List<HomeworkEntity> homeworks;
  final Map<String, HomeworkSubmissionEntity> submissionByHomeworkId;
  final String studentId;
  final StudentEntity student;
  final void Function(HomeworkEntity homework) onHomeworkTap;

  HomeworkSubmissionStatus _displayStatus(HomeworkEntity h) {
    final sub = submissionByHomeworkId[h.id];
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final endDay = DateTime(h.endDate.year, h.endDate.month, h.endDate.day);
    if (sub != null && sub.isCompleted) return HomeworkSubmissionStatus.approved;
    if (endDay.isBefore(today)) return HomeworkSubmissionStatus.pending;
    if (sub?.status == HomeworkSubmissionStatus.missing) return HomeworkSubmissionStatus.missing;
    if (sub?.status == HomeworkSubmissionStatus.notDone) return HomeworkSubmissionStatus.notDone;
    return HomeworkSubmissionStatus.missing;
  }

  @override
  Widget build(BuildContext context) {
    if (homeworks.isEmpty) {
      return const Center(
        child: Text(
          'Ödev bulunamadı',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: homeworks.length,
      itemBuilder: (context, index) {
        final h = homeworks[index];
        return InkWell(
          onTap: () => onHomeworkTap(h),
          borderRadius: BorderRadius.circular(12),
          child: HomeworkDetailCard(
            homework: h,
            displayStatus: _displayStatus(h),
          ),
        );
      },
    );
  }
}
