import 'package:flutter/material.dart';
import 'package:polen_academy/domain/homework/usecases/get_completed_homeworks_for_coach.dart';
import 'package:polen_academy/presentation/coach/home/widget/completed_homeworks_section.dart';

/// Koç anasayfada gecikmiş ödevleri tamamlanan ödevler bölümüyle aynı yapıda listeler.
/// Süresi geçmiş, henüz tamamlandı/tamamlanmadı/eksik işaretlenmemiş ödevler.
class OverdueHomeworkSection extends StatelessWidget {
  const OverdueHomeworkSection({
    super.key,
    this.items = const [],
    required this.onTap,
    required this.onRefresh,
  });

  final List<CompletedHomeworkItem> items;
  final void Function(CompletedHomeworkItem item) onTap;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return CompletedHomeworkSection(
      title: 'Gecikmiş Ödevler',
      subtitle: '',
      emptyMessage: 'Gecikmiş ödev yok.',
      items: items,
      onTap: onTap,
      onRefresh: onRefresh,
    );
  }
}
