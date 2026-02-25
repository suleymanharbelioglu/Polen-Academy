import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polen_academy/common/helper/navigator/app_navigator.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/data/auth/model/coach.dart';
import 'package:polen_academy/presentation/coach/auth/bloc/coach_creation_req_state.dart';
import 'package:polen_academy/presentation/coach/auth/bloc/coach_cretation_req_cubit.dart';
import 'package:polen_academy/presentation/coach/auth/widget/coach_sign_up_widgets.dart';
import 'package:polen_academy/presentation/coach/bottom_navbar/page/bottom_navbar.dart';

class CoachSignUpPage extends StatelessWidget {
  const CoachSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoachCretationReqCubit(),
      child: const _CoachSignUpPageContent(),
    );
  }
}

class _CoachSignUpPageContent extends StatefulWidget {
  const _CoachSignUpPageContent();

  @override
  State<_CoachSignUpPageContent> createState() =>
      _CoachSignUpPageContentState();
}

class _CoachSignUpPageContentState extends State<_CoachSignUpPageContent> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: 'süleyman');
  final _lastNameController = TextEditingController(text: 'harbelioğlu');
  final _emailController = TextEditingController(
    text: 'harba.suleyman@gmail.com',
  );
  final _passwordController = TextEditingController(text: 'cmylmZ.31');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    print('📝 Form gönderildi');
    if (_formKey.currentState?.validate() ?? false) {
      print('✅ Validasyon başarılı');
      final coach = CoachModel(
        uid: '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('🚀 Kayıt işlemi başlatılıyor...');
      context.read<CoachCretationReqCubit>().createCoach(coach);
    } else {
      print('❌ Validasyon başarısız');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoachCretationReqCubit, CoachCreationReqState>(
      listener: (context, state) {
        print('🔔 State değişti: ${state.runtimeType}');
        if (state is CoachCreationReqSuccess) {
          print('✅ Success state alındı, yönlendiriliyor...');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppNavigator.pushAndRemove(context, const BottomNavbarPage());
          });
        } else if (state is CoachCreationReqFailure) {
          print('❌ Failure state: ${state.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.secondBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      const CoachSignUpTitleSection(),
                      const SizedBox(height: 24),
                      CoachSignUpFormSection(
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                      ),
                      const SizedBox(height: 24),
                      CoachSignUpNextButton(onPressed: _handleSignUp),
                      const SizedBox(height: 16),
                      const CoachSignUpLoginText(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CoachSignUpBackToHome(),
      ),
    );
  }
}
