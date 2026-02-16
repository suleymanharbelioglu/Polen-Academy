import 'package:equatable/equatable.dart';

abstract class OpenStudentDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OpenStudentDetailInitial extends OpenStudentDetailState {}

class OpenStudentDetailRequested extends OpenStudentDetailState {}
