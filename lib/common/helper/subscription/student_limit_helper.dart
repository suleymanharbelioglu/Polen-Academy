import 'package:polen_academy/core/configs/revenuecat_config.dart';

class StudentLimitHelper {
  StudentLimitHelper._();

  static int effectiveLimit({required int? storedLimit, required bool isVip}) {
    if (storedLimit != null && storedLimit > 0) return storedLimit;
    if (isVip) return RevenueCatConfig.studentTiers.last;
    return RevenueCatConfig.freeStudentLimit;
  }

  static bool canAddStudent({
    required int currentStudentCount,
    required int studentLimit,
  }) =>
      currentStudentCount < studentLimit;

  static String limitMessage(int studentLimit) {
    if (studentLimit <= RevenueCatConfig.freeStudentLimit) {
      return 'Ücretsiz planda en fazla ${RevenueCatConfig.freeStudentLimit} öğrenci ekleyebilirsiniz.';
    }
    return 'Mevcut planınızda en fazla $studentLimit öğrenci ekleyebilirsiniz.';
  }
}
