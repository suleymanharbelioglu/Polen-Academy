class StudentEntity {
  final String uid;
  final String studentName;
  final String studentSurname;
  final String email;
  final String studentClass;
  final String coachId;
  final String parentId;
  final int progress;
  /// Whether the student has an assigned parent. Set at creation / when parent is added.
  final bool hasParent;

  StudentEntity({
    required this.uid,
    required this.studentName,
    required this.studentSurname,
    required this.email,
    required this.studentClass,
    required this.coachId,
    required this.parentId,
    required this.progress,
    this.hasParent = false,
  });

  StudentEntity copyWith({
    String? uid,
    String? studentName,
    String? studentSurname,
    String? email,
    String? studentClass,
    String? coachId,
    String? parentId,
    int? progress,
    bool? hasParent,
  }) {
    return StudentEntity(
      uid: uid ?? this.uid,
      studentName: studentName ?? this.studentName,
      studentSurname: studentSurname ?? this.studentSurname,
      email: email ?? this.email,
      studentClass: studentClass ?? this.studentClass,
      coachId: coachId ?? this.coachId,
      parentId: parentId ?? this.parentId,
      progress: progress ?? this.progress,
      hasParent: hasParent ?? this.hasParent,
    );
  }
}
