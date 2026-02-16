/// One-time credentials returned when a student is created (e.g. from Firebase).
/// Used by domain/UI; populated from [StudentCreationResult] model in data layer.
class StudentCredentialsEntity {
  final String email;
  final String password;

  const StudentCredentialsEntity({
    required this.email,
    required this.password,
  });
}
