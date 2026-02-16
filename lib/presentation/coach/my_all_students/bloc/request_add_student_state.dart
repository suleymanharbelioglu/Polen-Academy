import 'package:equatable/equatable.dart';

abstract class RequestAddStudentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RequestAddStudentInitial extends RequestAddStudentState {}

class RequestAddStudentOpenDialog extends RequestAddStudentState {}
