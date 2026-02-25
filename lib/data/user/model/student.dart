import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

class StudentModel {
  final String uid;
  final String studentName;
  final String studentSurname;
  final String email;
  final String studentClass;
  final String coachId;
  final String parentId;
  final int progress;
  /// Whether the student has an assigned parent.
  final bool hasParent;
  final DateTime? registeredAt;
  final List<String> focusCourseIds;

  StudentModel({
    required this.uid,
    required this.studentName,
    required this.studentSurname,
    required this.email,
    required this.studentClass,
    required this.coachId,
    required this.parentId,
    required this.progress,
    this.hasParent = false,
    this.registeredAt,
    this.focusCourseIds = const [],
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    final parentId = map['parentId'] ?? '';
    DateTime? registeredAt;
    final r = map['registeredAt'] ?? map['createdAt'];
    if (r != null) {
      if (r is DateTime) registeredAt = r;
      else if (r is String) registeredAt = DateTime.tryParse(r);
      else if (r is Timestamp) registeredAt = r.toDate();
    }
    return StudentModel(
      uid: map['uid'] ?? '',
      studentName: map['studentName'] ?? '',
      studentSurname: map['studentSurname'] ?? '',
      email: map['email'] ?? '',
      studentClass: map['studentClass'] ?? '',
      coachId: map['coachId'] ?? '',
      parentId: parentId,
      progress: map['progress'] ?? 0,
      hasParent: map['hasParent'] as bool? ?? parentId.toString().isNotEmpty,
      registeredAt: registeredAt,
      focusCourseIds: (map['focusCourseIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'uid': uid,
      'studentName': studentName,
      'studentSurname': studentSurname,
      'email': email,
      'studentClass': studentClass,
      'coachId': coachId,
      'parentId': parentId,
      'progress': progress,
      'hasParent': hasParent,
      'role': 'student',
    };
    if (registeredAt != null) m['registeredAt'] = registeredAt!.toIso8601String();
    if (focusCourseIds.isNotEmpty) m['focusCourseIds'] = focusCourseIds;
    return m;
  }
}

extension StudentModelX on StudentModel {
  StudentEntity toEntity() {
    return StudentEntity(
      uid: uid,
      studentName: studentName,
      studentSurname: studentSurname,
      email: email,
      studentClass: studentClass,
      coachId: coachId,
      parentId: parentId,
      progress: progress,
      hasParent: hasParent,
      registeredAt: registeredAt,
      focusCourseIds: focusCourseIds,
    );
  }
}

extension StudentEntityX on StudentEntity {
  StudentModel toModel() {
    return StudentModel(
      uid: uid,
      studentName: studentName,
      studentSurname: studentSurname,
      email: email,
      studentClass: studentClass,
      coachId: coachId,
      parentId: parentId,
      progress: progress,
      hasParent: hasParent,
      registeredAt: registeredAt,
      focusCourseIds: focusCourseIds,
    );
  }
}
