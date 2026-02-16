import 'package:equatable/equatable.dart';

abstract class LogoutState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LogoutInitial extends LogoutState {}

class LogoutLoading extends LogoutState {}

class LogoutSuccess extends LogoutState {}

class LogoutFailure extends LogoutState {
  final String errorMessage;

  LogoutFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
