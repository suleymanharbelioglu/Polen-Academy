import 'package:polen_academy/domain/auth/entity/parent_credentials_entity.dart';

abstract class ParentSignupState {}

class ParentSignupInitial extends ParentSignupState {}

class ParentSignupLoading extends ParentSignupState {}

class ParentSignupSuccess extends ParentSignupState {
  final ParentCredentialsEntity credentials;

  ParentSignupSuccess({required this.credentials});
}

class ParentSignupFailure extends ParentSignupState {
  final String errorMessage;

  ParentSignupFailure({required this.errorMessage});
}
