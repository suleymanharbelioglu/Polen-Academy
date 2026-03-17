class StudentHelper {
  static List<String> getClassLevels() {
    return [
      '1. Sınıf',
      '2. Sınıf',
      '3. Sınıf',
      '4. Sınıf',
      '5. Sınıf',
      '6. Sınıf',
      '7. Sınıf',
      '8. Sınıf',
      '9. Sınıf',
      '10. Sınıf',
      '11. Sınıf',
      '12. Sınıf',
      'Mezun',
    ];
  }

  /// 11, 12 veya Mezun için alan seçenekleri. Konuları değiştirmez, sadece kayıt için.
  static List<String> getAcademicFieldOptions() {
    return [
      'Alan Seçilmedi',
      'Sayısal (MF)',
      'Eşit Ağırlık (TM)',
      'Sözel (TS)',
      'Yabancı Dil',
    ];
  }

  static bool isClassWithAcademicField(String classLevel) {
    return classLevel == '11. Sınıf' || classLevel == '12. Sınıf' || classLevel == 'Mezun';
  }

  /// 11. sınıf: 11. Sınıf + TYT; 12 / Mezun: TYT + AYT + YDS
  static bool isClassWithExamSections(String classLevel) {
    return classLevel == '11. Sınıf' || classLevel == '12. Sınıf' || classLevel == 'Mezun';
  }

  static String generateParentId(String studentName) {
    // Öğrenci adından veli ID'si üret
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanName = studentName.toLowerCase().replaceAll(' ', '_');
    return 'parent_${cleanName}_$timestamp';
  }
}
