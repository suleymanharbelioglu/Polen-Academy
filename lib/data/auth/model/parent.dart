import 'package:polen_academy/domain/user/entity/parent_entity.dart';

class ParentModel {
  final String uid;
  final String parentName;
  final String parentSurname;
  final String email;
  final String coachId;
  final String studentId;

  ParentModel({
    required this.uid,
    required this.parentName,
    required this.parentSurname,
    required this.email,
    required this.coachId,
    required this.studentId,
  });

  factory ParentModel.fromMap(Map<String, dynamic> map) {
    return ParentModel(
      uid: map['uid'] ?? '',
      parentName: map['parentName'] ?? '',
      parentSurname: map['parentSurname'] ?? '',
      email: map['email'] ?? '',
      coachId: map['coachId'] ?? '',
      studentId: map['studentId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'parentName': parentName,
      'parentSurname': parentSurname,
      'email': email,
      'coachId': coachId,
      'studentId': studentId,
      'role': 'parent',
    };
  }
}

extension ParentModelX on ParentModel {
  ParentEntity toEntity() {
    return ParentEntity(
      uid: uid,
      parentName: parentName,
      parentSurname: parentSurname,
      email: email,
      coachId: coachId,
      studentId: studentId,
    );
  }
}

extension ParentEntityX on ParentEntity {
  ParentModel toModel() {
    return ParentModel(
      uid: uid,
      parentName: parentName,
      parentSurname: parentSurname,
      email: email,
      coachId: coachId,
      studentId: studentId,
    );
  }
}
