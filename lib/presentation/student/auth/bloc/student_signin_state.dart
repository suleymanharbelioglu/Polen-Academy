abstract class StudentSigninState {}

class StudentSigninInitial extends StudentSigninState {}

class StudentSigninLoading extends StudentSigninState {}

class StudentSigninSuccess extends StudentSigninState {}

class StudentSigninFailure extends StudentSigninState {
  final String errorMessage;

  StudentSigninFailure({required this.errorMessage});
}
