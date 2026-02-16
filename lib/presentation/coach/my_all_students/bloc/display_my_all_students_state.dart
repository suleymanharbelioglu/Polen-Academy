import 'package:equatable/equatable.dart';
import 'package:polen_academy/domain/user/entity/student_entity.dart';

abstract class DisplayMyAllStudentsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DisplayMyAllStudentsInitial extends DisplayMyAllStudentsState {}

class DisplayMyAllStudentsLoading extends DisplayMyAllStudentsState {}

class DisplayMyAllStudentsSuccess extends DisplayMyAllStudentsState {
  final List<StudentEntity> students;

  DisplayMyAllStudentsSuccess({required this.students});

  @override
  List<Object?> get props => [students];
}

class DisplayMyAllStudentsFailure extends DisplayMyAllStudentsState {
  final String errorMessage;

  DisplayMyAllStudentsFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
