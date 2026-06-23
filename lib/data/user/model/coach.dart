import 'package:polen_academy/domain/user/entity/coach_entity.dart';

class CoachModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool isVip;
  final int? studentLimit;
  final String? subscriptionProductId;

  CoachModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.isVip = false,
    this.studentLimit,
    this.subscriptionProductId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'isVip': isVip,
      if (studentLimit != null) 'studentLimit': studentLimit,
      if (subscriptionProductId != null) 'subscriptionProductId': subscriptionProductId,
    };
  }

  factory CoachModel.fromMap(Map<String, dynamic> map) {
    final rawLimit = map['studentLimit'];
    return CoachModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'coach',
      isVip: map['isVip'] == true,
      studentLimit: rawLimit is int ? rawLimit : int.tryParse('$rawLimit'),
      subscriptionProductId: map['subscriptionProductId'] as String?,
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
      studentLimit: studentLimit,
      subscriptionProductId: subscriptionProductId,
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
      studentLimit: studentLimit,
      subscriptionProductId: subscriptionProductId,
    );
  }
}
