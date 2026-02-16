/// One-time credentials returned when a parent is created (e.g. from Firebase).
class ParentCredentialsEntity {
  final String email;
  final String password;
  final String parentUid;

  const ParentCredentialsEntity({
    required this.email,
    required this.password,
    required this.parentUid,
  });
}
