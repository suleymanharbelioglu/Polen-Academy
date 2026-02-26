import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';

class GeneralProgressSection extends StatelessWidget {
  const GeneralProgressSection({
    super.key,
    required this.state,
    this.minDiameter = 200,
    this.maxDiameter = 400,
    this.strokeWidth = 20,
    this.accentColor,
  });

  final StudentDetailState state;
  /// Öğrenci profil sayfasında primaryStudent; null ise primaryCoach.
  final Color? accentColor;

  /// Genel ilerleme dairesinin minimum çapı.
  final double minDiameter;

  /// Genel ilerleme dairesinin maximum çapı.
  final double maxDiameter;

  /// Daire progress bar çizgisinin kalınlığı.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final percent = state.overallProgressPercent.clamp(0, 100);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Genel İlerleme',
            style: TextStyle(
              color: accentColor ?? AppColors.primaryCoach,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final diameter = (constraints.maxWidth - 24).clamp(
                minDiameter,
                maxDiameter,
              );
              return GeneralProgressCircle(
                percent: percent,
                diameter: diameter,
                strokeWidth: strokeWidth,
                accentColor: accentColor,
              );
            },
          ),
        ],
      ),
    );
  }
}

class GeneralProgressCircle extends StatelessWidget {
  const GeneralProgressCircle({
    super.key,
    required this.percent,
    this.diameter,
    this.strokeWidth = 20,
    this.showPercent = true,
    this.accentColor,
    this.backgroundColor,
  });

  final int percent;
  final double? diameter;

  /// Daire progress bar çizgisinin kalınlığı.
  final double strokeWidth;

  /// Ortada yüzde yazısı gösterilsin mi (örn. kartlarda yazı olmasın).
  final bool showPercent;

  final Color? accentColor;

  /// Daire arka plan (boş kısım) rengi. Null ise Colors.white24.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final size = diameter ?? 220.0;
    final color = accentColor ?? AppColors.primaryCoach;
    final bgColor = backgroundColor ?? Colors.white24;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: (percent.clamp(0, 100)) / 100,
              strokeWidth: strokeWidth,
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (showPercent)
            Text(
              '$percent%',
              style: TextStyle(
                color: color,
                fontSize: size * 0.16,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
