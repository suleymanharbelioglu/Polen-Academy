/// Result from Cloud Function createParent: generated email, password and parent uid.
class ParentCreationResult {
  final String email;
  final String password;
  final String uid;

  ParentCreationResult({
    required this.email,
    required this.password,
    required this.uid,
  });
}
