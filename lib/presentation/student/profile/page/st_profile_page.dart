import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/source/auth_firebase_service.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/domain/user/usecases/get_student_by_uid.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_cubit.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/class_progress_section.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/general_progress_section.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/homework_status_section.dart';
import 'package:polen_academy/presentation/coach/student_detail/widget/profile_section.dart';
import 'package:polen_academy/service_locator.dart';

/// Öğrenci kendi profil sayfası: koç öğrenci detayıyla aynı içerik (profil, ödev durumları, genel/sınıf ilerleme).
/// Veli işlemleri ve şifre değiştirme yok.
class StProfilePage extends StatefulWidget {
  const StProfilePage({super.key});

  @override
  State<StProfilePage> createState() => _StProfilePageState();
}

class _StProfilePageState extends State<StProfilePage> {
  StudentEntity? _student;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    final uid = sl<AuthFirebaseService>().getCurrentUserUid() ?? '';
    if (uid.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Oturum bilgisi alınamadı.';
      });
      return;
    }
    final result = await sl<GetStudentByUidUseCase>().call(params: uid);
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
          title: const Text('Profilim'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryStudent),
        ),
      );
    }
    if (_error != null || _student == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.secondBackground,
          foregroundColor: Colors.white,
          title: const Text('Profilim'),
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
                  _error ?? 'Profil bilgisi yüklenemedi.',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _loadStudent(),
                  child: const Text(
                    'Tekrar dene',
                    style: TextStyle(color: AppColors.primaryStudent),
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
          title: const Text('Profilim'),
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
                child: CircularProgressIndicator(color: AppColors.primaryStudent),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<StudentDetailCubit>().load(student, student.coachId);
              },
              color: AppColors.primaryStudent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileSection(
                      student: student,
                      accentColor: AppColors.primaryStudent,
                    ),
                    const SizedBox(height: 20),
                    HomeworkStatusSection(state: state),
                    const SizedBox(height: 20),
                    GeneralProgressSection(
                      state: state,
                      accentColor: AppColors.primaryStudent,
                    ),
                    const SizedBox(height: 20),
                    ClassProgressSection(
                      state: state,
                      accentColor: AppColors.primaryStudent,
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
