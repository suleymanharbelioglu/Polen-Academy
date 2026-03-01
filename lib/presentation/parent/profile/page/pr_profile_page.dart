import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/usecases/get_student_by_parent_id.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_cubit.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/class_progress_section.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/general_progress_section.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/profile_section.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/status_sections_with_range.dart';
import 'package:polen_academy/presentation/homework_detail/page/homework_detail_page.dart';
import 'package:polen_academy/presentation/session_detail/page/session_detail_page.dart';
import 'package:polen_academy/service_locator.dart';

/// Veli profil sayfası: bağlı olduğu öğrencinin profil/seans/ödev durumu (öğrenciyle aynı içerik).
/// Ödev detayında "Yaptım olarak işaretle" butonu yok.
class PrProfilePage extends StatefulWidget {
  const PrProfilePage({super.key});

  @override
  State<PrProfilePage> createState() => _PrProfilePageState();
}

class _PrProfilePageState extends State<PrProfilePage> {
  StudentEntity? _student;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    final parentUid = sl<AuthFirebaseService>().getCurrentUserUid() ?? '';
    if (parentUid.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Oturum bilgisi alınamadı.';
      });
      return;
    }
    final result = await sl<GetStudentByParentIdUseCase>().call(params: parentUid);
    if (!mounted) return;
    result.fold(
      (e) => setState(() {
        _loading = false;
        _error = e;
        _student = null;
      }),
      (student) => setState(() {
        _loading = false;
        _error = null;
        _student = student;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.secondBackground,
          foregroundColor: Colors.white,
          title: const Text('Öğrencimin Profili'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryParent),
        ),
      );
    }
    if (_error != null || _student == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.secondBackground,
          foregroundColor: Colors.white,
          title: const Text('Öğrencimin Profili'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _error ?? 'Öğrenci bilgisi yüklenemedi.',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _loadStudent(),
                  child: const Text(
                    'Tekrar dene',
                    style: TextStyle(color: AppColors.primaryParent),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final student = _student!;
    return BlocProvider(
      create: (_) => StudentDetailCubit()..load(student, student.coachId),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.secondBackground,
          foregroundColor: Colors.white,
          title: const Text('Öğrencimin Profili'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<StudentDetailCubit, StudentDetailState>(
          builder: (context, state) {
            if (state.loading &&
                state.overdueCount == 0 &&
                state.completedHomeworkCount == 0 &&
                state.courseProgressPercent.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryParent),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<StudentDetailCubit>().load(student, student.coachId);
              },
              color: AppColors.primaryParent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileSection(
                      student: student,
                      accentColor: AppColors.primaryParent,
                    ),
                    const SizedBox(height: 20),
                    StatusSectionsWithRange(
                      state: state,
                      student: student,
                      accentColor: AppColors.primaryParent,
                      onHomeworkDetailsTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => HomeworkDetailPage(
                            student: student,
                            useStudentDetailSheet: true,
                            showMarkAsDone: false,
                          ),
                        ),
                      ),
                      onSessionDetailsTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => SessionDetailPage(student: student),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GeneralProgressSection(
                      state: state,
                      accentColor: AppColors.primaryParent,
                    ),
                    const SizedBox(height: 20),
                    ClassProgressSection(
                      state: state,
                      accentColor: AppColors.primaryParent,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
