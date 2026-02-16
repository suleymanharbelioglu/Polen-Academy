import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/helper/student/student_helper.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/student_creation_req_cubit.dart';
import 'package:polen_academy/presentation/coach/my_all_students/bloc/student_creation_req_state.dart';

class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({super.key});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _selectedClass = '1. Sınıf';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'classLevel': _selectedClass,
      };
      context.read<StudentCreationReqCubit>().createStudentFromFormData(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentCreationReqCubit, StudentCreationReqState>(
      listener: (context, state) {
        if (state is StudentCreationReqSuccess) {
          Navigator.pop(context, state.credentials);
        } else if (state is StudentCreationReqFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is StudentCreationReqLoading;

        return AlertDialog(
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
                children: [
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'Ad',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ad gerekli';
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
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
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Ekle', style: TextStyle(color: Colors.white)),
            ),
          ],
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
        if (newValue != null) {
          setState(() {
            _selectedClass = newValue;
          });
        }
      },
    );
  }
}
