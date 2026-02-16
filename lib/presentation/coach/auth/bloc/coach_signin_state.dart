import 'package:equatable/equatable.dart';

abstract class CoachSigninState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CoachSigninInitial extends CoachSigninState {}

class CoachSigninLoading extends CoachSigninState {}

class CoachSigninSuccess extends CoachSigninState {}

class CoachSigninFailure extends CoachSigninState {
  final String errorMessage;

  CoachSigninFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
