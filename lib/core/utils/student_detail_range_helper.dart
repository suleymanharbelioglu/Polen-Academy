import 'package:polen_academy/domain/user/entity/student_entity.dart';
import 'package:polen_academy/presentation/coach/student_detail/bloc/student_detail_state.dart';

/// Ödev ve seans listeleri için tarih aralığı. UI ve Cubit'te tek kaynak.
class StudentDetailRangeHelper {
  StudentDetailRangeHelper._();

  static const int futureDays = 60;

  /// Aralık başlangıcı; kayıt tarihinden önce gitmez.
  static DateTime rangeStart(
    StudentDetailRangeFilter filter,
    StudentEntity student,
    DateTime now,
  ) {
    final reg = student.registeredAt != null
        ? DateTime(
            student.registeredAt!.year,
            student.registeredAt!.month,
            student.registeredAt!.day,
          )
        : null;
    final DateTime requested;
    switch (filter) {
      case StudentDetailRangeFilter.lastWeek:
        requested = now.subtract(const Duration(days: 7));
        break;
      case StudentDetailRangeFilter.lastMonth:
        requested = now.subtract(const Duration(days: 30));
        break;
      case StudentDetailRangeFilter.all:
        requested = reg ?? now.subtract(const Duration(days: 365));
        break;
    }
    if (reg != null && requested.isBefore(reg)) return reg;
    return requested;
  }

  /// Aralık bitişi. "Tümü" seçiliyken geleceği de kapsar.
  static DateTime rangeEnd(StudentDetailRangeFilter filter, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (filter == StudentDetailRangeFilter.all) {
      return today.add(const Duration(days: futureDays));
    }
    return today;
  }

  /// Seans sorgusu için bitiş (her zaman geleceği de içerir).
  static DateTime sessionQueryEnd(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return today.add(const Duration(days: futureDays));
  }
}
