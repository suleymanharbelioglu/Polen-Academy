import 'package:polen_academy/domain/user/entity/coach_entity.dart';

class CoachModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  CoachModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
    };
  }

  factory CoachModel.fromMap(Map<String, dynamic> map) {
    return CoachModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'coach',
    );
  }
}

extension CoachModelX on CoachModel {
  CoachEntity toEntity() {
    return CoachEntity(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role,
    );
  }
}

extension CoachEntityX on CoachEntity {
  CoachModel toModel() {
    return CoachModel(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role,
    );
  }
}
