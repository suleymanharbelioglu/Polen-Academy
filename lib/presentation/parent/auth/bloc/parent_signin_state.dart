abstract class ParentSigninState {}

class ParentSigninInitial extends ParentSigninState {}

class ParentSigninLoading extends ParentSigninState {}

class ParentSigninSuccess extends ParentSigninState {}

class ParentSigninFailure extends ParentSigninState {
  final String errorMessage;

  ParentSigninFailure({required this.errorMessage});
}
