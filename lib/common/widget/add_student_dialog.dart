import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/helper/student/student_helper.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/domain/curriculum/entity/course_entity.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/curriculum/usecases/get_curriculum_tree.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/student_creation_req_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/student_creation_req_state.dart';
import 'package:polen_academy/service_locator.dart';

class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({super.key});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _selectedClass = '5. Sınıf';
  List<CourseEntity> _coursesForClass = [];
  bool _loadingCourses = false;
  final Set<String> _selectedCourseIds = {};

  @override
  void initState() {
    super.initState();
    _loadCoursesForClass();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCoursesForClass() async {
    if (!mounted) return;
    LoadingOverlay.show(context);
    setState(() => _loadingCourses = true);
    final result = await sl<GetCurriculumTreeUseCase>().call(
      params: _selectedClass,
    );
    if (!mounted) return;
    result.fold(
      (_) {
        LoadingOverlay.hide(context);
        setState(() {
          _coursesForClass = [];
          _loadingCourses = false;
        });
      },
      (CurriculumTree tree) {
        final courses = tree.courses.map((c) => c.course).toList();
        LoadingOverlay.hide(context);
        setState(() {
          _coursesForClass = courses;
          _loadingCourses = false;
          _selectedCourseIds.removeWhere(
            (id) => !courses.any((c) => c.id == id),
          );
        });
      },
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'classLevel': _selectedClass,
        'focusCourseIds': _selectedCourseIds.toList(),
      };
      context.read<StudentCreationReqCubit>().createStudentFromFormData(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentCreationReqCubit, StudentCreationReqState>(
      listener: (context, state) {
        if (state is StudentCreationReqLoading) {
          LoadingOverlay.show(context);
        } else if (state is StudentCreationReqSuccess) {
          LoadingOverlay.hide(context);
          if (context.mounted) Navigator.pop(context, state.credentials);
        } else if (state is StudentCreationReqFailure) {
          LoadingOverlay.hide(context);
          // Hata dialog içinde gösterilecek (SnackBar dialog arkasında kalıyor)
        }
      },
      builder: (context, state) {
        final isLoading = state is StudentCreationReqLoading;
        final errorMessage = state is StudentCreationReqFailure
            ? state.errorMessage
            : null;
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: width, maxWidth: width),
                child: AlertDialog(
                  insetPadding: EdgeInsets.zero,
                  backgroundColor: AppColors.secondBackground,
                  title: const Text(
                    'Öğrenci Ekle',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (errorMessage != null &&
                              errorMessage.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.shade700,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade300,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      errorMessage,
                                      style: TextStyle(
                                        color: Colors.red.shade100,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          _buildTextField(
                            controller: _firstNameController,
                            label: 'Ad',
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Ad gerekli';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _lastNameController,
                            label: 'Soyad',
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Soyad gerekli';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildClassDropdown(),
                          const SizedBox(height: 20),
                          const Text(
                            'Öğrencinin odaklanacağı dersler',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_loadingCourses)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Dersler yükleniyor...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          else if (_coursesForClass.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Bu sınıf için ders listesi yüklenemedi.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            )
                          else ...[
                            Text(
                              '$_selectedClass Dersleri',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._coursesForClass.map(
                              (course) => CheckboxListTile(
                                value: _selectedCourseIds.contains(course.id),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedCourseIds.add(course.id);
                                    } else {
                                      _selectedCourseIds.remove(course.id);
                                    }
                                  });
                                },
                                title: Text(
                                  course.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                activeColor: AppColors.primaryCoach,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(
                        'İptal',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCoach,
                      ),
                      child: const Text(
                        'Öğrenciyi Ekle',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryCoach),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildClassDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedClass,
      dropdownColor: AppColors.secondBackground,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: 'Sınıf',
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryCoach),
        ),
      ),
      items: StudentHelper.getClassLevels().map((String classLevel) {
        return DropdownMenuItem<String>(
          value: classLevel,
          child: Text(classLevel),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null && newValue != _selectedClass) {
          setState(() => _selectedClass = newValue);
          _loadCoursesForClass();
        }
      },
    );
  }
}
