import 'package:equatable/equatable.dart';
import 'package:polen_academy/domain/auth/entity/student_credentials_entity.dart';

abstract class StudentCreationReqState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StudentCreationReqInitial extends StudentCreationReqState {}

class StudentCreationReqLoading extends StudentCreationReqState {}

class StudentCreationReqSuccess extends StudentCreationReqState {
  final StudentCredentialsEntity credentials;

  StudentCreationReqSuccess({required this.credentials});

  @override
  List<Object?> get props => [credentials];
}

class StudentCreationReqFailure extends StudentCreationReqState {
  final String errorMessage;

  StudentCreationReqFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
