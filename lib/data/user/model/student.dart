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
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    final parentId = map['parentId'] ?? '';
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
    );
  }
}
