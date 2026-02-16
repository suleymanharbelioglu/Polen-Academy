abstract class SplashState {}

class DisplaySplash extends SplashState {}

class UnAuthenticated extends SplashState {}

/// Emitted when user is logged in. [role] is 'coach', 'student', or 'parent'.
class Authenticated extends SplashState {
  final String role;

  Authenticated(this.role);
}

