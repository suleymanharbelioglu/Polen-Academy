import 'package:polen_academy/domain/user/entity/coach_entity.dart';

class CoachModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool isVip;

  CoachModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.isVip = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'isVip': isVip,
    };
  }

  factory CoachModel.fromMap(Map<String, dynamic> map) {
    return CoachModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'coach',
      isVip: map['isVip'] == true,
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
      isVip: isVip,
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
      isVip: isVip,
    );
  }
}
