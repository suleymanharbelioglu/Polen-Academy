import 'package:equatable/equatable.dart';

abstract class CoachCreationReqState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CoachCreationReqInitial extends CoachCreationReqState {}

class CoachCreationReqLoading extends CoachCreationReqState {}

class CoachCreationReqSuccess extends CoachCreationReqState {}

class CoachCreationReqFailure extends CoachCreationReqState {
  final String errorMessage;

  CoachCreationReqFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
