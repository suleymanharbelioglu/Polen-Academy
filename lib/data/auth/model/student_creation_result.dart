/// Result from Cloud Function createStudent: generated email and password.
class StudentCreationResult {
  final String email;
  final String password;

  StudentCreationResult({required this.email, required this.password});
}
