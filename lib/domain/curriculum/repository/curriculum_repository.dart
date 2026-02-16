import 'package:dartz/dartz.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/curriculum/entity/course_entity.dart';
import 'package:polen_academy/domain/curriculum/entity/unit_entity.dart';
import 'package:polen_academy/domain/curriculum/entity/topic_entity.dart';

abstract class CurriculumRepository {
  /// Returns full curriculum tree for a class level (e.g. "6. Sınıf").
  Future<Either<String, CurriculumTree>> getCurriculumTree(String classLevel);

  Future<Either<String, List<CourseEntity>>> getCoursesByClass(String classLevel);
  Future<Either<String, List<UnitEntity>>> getUnitsByCourse(String courseId);
  Future<Either<String, List<TopicEntity>>> getTopicsByUnit(String unitId);
}
