import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/widget/loading_overlay.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/parent_signup_cubit.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/parent_signup_state.dart';

class AddParentDialog extends StatefulWidget {
  final String coachId;
  final String studentId;

  const AddParentDialog({
    super.key,
    required this.coachId,
    required this.studentId,
  });

  @override
  State<AddParentDialog> createState() => _AddParentDialogState();
}

class _AddParentDialogState extends State<AddParentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      LoadingOverlay.show(context);
      context.read<ParentSignupCubit>().createParentFromFormData(
            parentName: _firstNameController.text.trim(),
            parentSurname: _lastNameController.text.trim(),
            coachId: widget.coachId,
            studentId: widget.studentId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParentSignupCubit, ParentSignupState>(
      listener: (context, state) {
        if (state is ParentSignupSuccess) {
          LoadingOverlay.hide(context);
          Navigator.pop(context, state.credentials);
        } else if (state is ParentSignupFailure) {
          LoadingOverlay.hide(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ParentSignupLoading;

        return AlertDialog(
          backgroundColor: AppColors.secondBackground,
          title: const Text(
            'Veli Ekle',
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
              child: const Text('Ekle', style: TextStyle(color: Colors.white)),
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
  }) {
    return TextFormField(
      controller: controller,
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
}
