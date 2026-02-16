import 'package:polen_academy/domain/curriculum/entity/course_entity.dart';

class CourseModel {
  final String id;
  final String name;
  final String classLevel;

  CourseModel({
    required this.id,
    required this.name,
    required this.classLevel,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      classLevel: map['classLevel'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'classLevel': classLevel,
    };
  }

  CourseEntity toEntity() => CourseEntity(
        id: id,
        name: name,
        classLevel: classLevel,
      );
}
