import 'package:flutter/material.dart';
import 'package:polen_academy/core/configs/theme/app_colors.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';

class ClassProgressSection extends StatelessWidget {
  const ClassProgressSection({
    super.key,
    required this.state,
    this.circleDiameter = 130,
    this.circleStrokeWidth = 12,
    this.accentColor,
  });

  final StudentDetailState state;
  /// Öğrenci profil sayfasında primaryStudent; null ise primaryCoach.
  final Color? accentColor;

  /// Her ders ilerleme dairesinin çapı.
  final double circleDiameter;

  /// Daire progress bar çizgisinin kalınlığı.
  final double circleStrokeWidth;

  @override
  Widget build(BuildContext context) {
    final classLevel = state.student?.studentClass ?? '';
    if (classLevel.isEmpty || state.courseProgressPercent.isEmpty) {
      return const SizedBox.shrink();
    }

    final entries = state.courseProgressPercent.entries.toList();
    final rowCount = (entries.length / 2).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$classLevel İlerleme Durumu',
            style: TextStyle(
              color: accentColor ?? AppColors.primaryCoach,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(rowCount, (rowIndex) {
            final start = rowIndex * 2;
            final end = (start + 2).clamp(0, entries.length);
            final rowItems = entries.sublist(start, end);
            return Padding(
              padding: EdgeInsets.only(
                bottom: rowIndex < rowCount - 1 ? 28 : 0,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < 2; i++)
                    Expanded(
                      child: i < rowItems.length
                          ? Padding(
                              padding: EdgeInsets.only(
                                right: i == 0 ? 20 : 0,
                                left: i == 1 ? 20 : 0,
                              ),
                              child: CircularProgressItem(
                                courseName: rowItems[i].key,
                                percent: rowItems[i].value,
                                diameter: circleDiameter,
                                strokeWidth: circleStrokeWidth,
                                accentColor: accentColor,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class CircularProgressItem extends StatelessWidget {
  const CircularProgressItem({
    super.key,
    required this.courseName,
    required this.percent,
    this.diameter = 130,
    this.strokeWidth = 12,
    this.accentColor,
  });

  final String courseName;
  final int percent;

  /// Dairenin çapı (genişlik / yükseklik).
  final double diameter;

  /// Daire progress bar çizgisinin kalınlığı.
  final double strokeWidth;

  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primaryCoach;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: diameter,
                height: diameter,
                child: CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: color,
                  fontSize: (diameter * 0.15).clamp(14.0, 28.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          courseName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ],
    );
  }
}
