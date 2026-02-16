import 'package:polen_academy/domain/curriculum/entity/course_entity.dart';
import 'package:polen_academy/domain/curriculum/entity/topic_entity.dart';
import 'package:polen_academy/domain/curriculum/entity/unit_entity.dart';

class UnitWithTopics {
  final UnitEntity unit;
  final List<TopicEntity> topics;

  UnitWithTopics({required this.unit, required this.topics});
}

class CourseWithUnits {
  final CourseEntity course;
  final List<UnitWithTopics> units;

  CourseWithUnits({required this.course, required this.units});
}

class CurriculumTree {
  final List<CourseWithUnits> courses;

  CurriculumTree({required this.courses});
}
