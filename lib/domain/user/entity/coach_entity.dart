class CoachEntity {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool isVip;
  final int? studentLimit;
  final String? subscriptionProductId;

  CoachEntity({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.isVip = false,
    this.studentLimit,
    this.subscriptionProductId,
  });
}
