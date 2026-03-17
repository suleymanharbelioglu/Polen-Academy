import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/helper/student/student_helper.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/core/network/network_error_helper.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/add_student_form_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/student_creation_req_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/student_creation_req_state.dart';

class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({super.key});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
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
        }
      },
      builder: (context, state) {
        final isLoading = state is StudentCreationReqLoading;
        final errorMessage = state is StudentCreationReqFailure
            ? NetworkErrorHelper.getUserFriendlyMessage(state.errorMessage)
            : null;
          return LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: maxWidth,
                    maxWidth: maxWidth,
                  ),
                  child: AlertDialog(
                    insetPadding: const EdgeInsets.symmetric(horizontal: 8),
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
                            _ErrorBanner(message: errorMessage),
                          ],
                          _buildTextField(
                            onChanged: context
                                .read<AddStudentFormCubit>()
                                .setFirstName,
                            label: 'Ad',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ad gerekli';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            onChanged: context
                                .read<AddStudentFormCubit>()
                                .setLastName,
                            label: 'Soyad',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Soyad gerekli';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildClassDropdown(),
                          const _AcademicFieldSection(),
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
                          const _ExamSectionsRow(),
                          const SizedBox(height: 12),
                          const _CoursesList(),
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
                      onPressed: isLoading
                          ? null
                          : () => _handleSubmit(context),
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

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final formState = context.read<AddStudentFormCubit>().state;
    if ((formState.selectedClass == '11. Sınıf' ||
            formState.selectedClass == 'Mezun') &&
        formState.selectedAcademicField == 'Alan Seçilmedi') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('11. Sınıf ve Mezun için alan seçimi zorunludur.'),
        ),
      );
      return;
    }
    final academicField =
        StudentHelper.isClassWithAcademicField(formState.selectedClass) &&
            formState.selectedAcademicField != 'Alan Seçilmedi'
        ? formState.selectedAcademicField
        : null;
    final data = {
      'firstName': formState.firstName,
      'lastName': formState.lastName,
      'classLevel': formState.selectedClass,
      'focusCourseIds': formState.selectedCourseIds.toList(),
      if (academicField != null) 'academicField': academicField,
    };
    context.read<StudentCreationReqCubit>().createStudentFromFormData(data);
  }

  Widget _buildTextField({
    required void Function(String) onChanged,
    required String label,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      onChanged: onChanged,
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
    final cubit = context.read<AddStudentFormCubit>();
    final selectedClass = cubit.state.selectedClass;
    return DropdownButtonFormField<String>(
      value: selectedClass,
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
      items: [
        const DropdownMenuItem<String>(
          value: 'Bir sınıf seçin',
          child: Text('Bir sınıf seçin'),
        ),
        ...StudentHelper.getClassLevels().map(
          (String classLevel) => DropdownMenuItem<String>(
            value: classLevel,
            child: Text(classLevel),
          ),
        ),
      ],
      onChanged: (String? newValue) {
        if (newValue != null) {
          cubit.setClass(newValue);
        }
      },
    );
  }

}

class _ExamSectionsRow extends StatelessWidget {
  const _ExamSectionsRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddStudentFormCubit, AddStudentFormState>(
      builder: (context, state) {
        if (!StudentHelper.isClassWithExamSections(state.selectedClass)) {
          return const SizedBox.shrink();
        }
        final cubit = context.read<AddStudentFormCubit>();
        final options = state.selectedClass == '11. Sınıf'
            ? ['11. Sınıf', 'TYT']
            : ['TYT', 'AYT', 'YDS'];
        return Wrap(
          spacing: 12,
          runSpacing: 4,
          children: options
              .map(
                (key) => FilterChip(
                  selected: state.enabledExamSections.contains(key),
                  label: Text(
                    key,
                    style: TextStyle(
                      color: state.enabledExamSections.contains(key)
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  selectedColor: AppColors.primaryCoach,
                  backgroundColor: Colors.white12,
                  showCheckmark: false,
                  onSelected: (value) => cubit.toggleExamSection(key, value),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade700, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade100, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoursesList extends StatelessWidget {
  const _CoursesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddStudentFormCubit, AddStudentFormState>(
      builder: (context, state) {
        if (state.loadingCourses) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Dersler yükleniyor...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          );
        }

        if (state.sections.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Bu sınıf için ders listesi yüklenemedi.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          );
        }

        final visibleSections = state.sections.where(
          (section) =>
              !StudentHelper.isClassWithExamSections(state.selectedClass) ||
              state.enabledExamSections.contains(
                AddStudentFormCubit.sectionKeyForTitle(section.title),
              ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: visibleSections.expand((section) {
            return [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Text(
                  section.title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...section.courses.map(
                (course) => CheckboxListTile(
                  value: state.selectedCourseIds.contains(course.id),
                  onChanged: (bool? value) {
                    context.read<AddStudentFormCubit>().toggleCourse(
                      course.id,
                      value ?? false,
                    );
                  },
                  title: Text(
                    course.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  activeColor: AppColors.primaryCoach,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ];
          }).toList(),
        );
      },
    );
  }
}

class _AcademicFieldSection extends StatelessWidget {
  const _AcademicFieldSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddStudentFormCubit, AddStudentFormState>(
      builder: (context, state) {
        if (!StudentHelper.isClassWithAcademicField(state.selectedClass)) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: state.selectedAcademicField,
              dropdownColor: AppColors.secondBackground,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Alan',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryCoach),
                ),
              ),
              items: StudentHelper.getAcademicFieldOptions().map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  context.read<AddStudentFormCubit>().setAcademicField(newValue);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
