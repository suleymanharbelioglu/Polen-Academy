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

  static String generateParentId(String studentName) {
    // Öğrenci adından veli ID'si üret
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanName = studentName.toLowerCase().replaceAll(' ', '_');
    return 'parent_${cleanName}_$timestamp';
  }
}
