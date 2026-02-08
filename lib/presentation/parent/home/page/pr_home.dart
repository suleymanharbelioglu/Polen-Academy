import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';

class PrHomePage extends StatelessWidget {
  const PrHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: const [
             
            ],
          ),
        ),
      ),
    );
  }
}
