import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/curriculum/source/curriculum_firebase_service.dart';
import 'package:polen_academy/domain/curriculum/entity/course_entity.dart';
import 'package:polen_academy/domain/curriculum/entity/curriculum_tree.dart';
import 'package:polen_academy/domain/curriculum/entity/topic_entity.dart';
import 'package:polen_academy/domain/curriculum/entity/unit_entity.dart';
import 'package:polen_academy/domain/curriculum/repository/curriculum_repository.dart';

class CurriculumRepositoryImpl extends CurriculumRepository {
  CurriculumRepositoryImpl(this._service);
  final CurriculumFirebaseService _service;

  @override
  Future<Either<String, CurriculumTree>> getCurriculumTree(String classLevel) async {
    final coursesResult = await getCoursesByClass(classLevel);
    return coursesResult.fold(
      (l) => Left(l),
      (courses) async {
        final courseWithUnits = <CourseWithUnits>[];
        for (final course in courses) {
          final unitsResult = await getUnitsByCourse(course.id);
          final units = unitsResult.getOrElse(() => <UnitEntity>[]);
          final unitWithTopics = <UnitWithTopics>[];
          for (final unit in units) {
            final topicsResult = await getTopicsByUnit(unit.id);
            final topics = topicsResult.getOrElse(() => <TopicEntity>[]);
            unitWithTopics.add(UnitWithTopics(unit: unit, topics: topics));
          }
          unitWithTopics.sort((a, b) => a.unit.order.compareTo(b.unit.order));
          courseWithUnits.add(CourseWithUnits(course: course, units: unitWithTopics));
        }
        return Right(CurriculumTree(courses: courseWithUnits));
      },
    );
  }

  @override
  Future<Either<String, List<CourseEntity>>> getCoursesByClass(String classLevel) async {
    final result = await _service.getCoursesByClass(classLevel);
    return result.map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<String, List<UnitEntity>>> getUnitsByCourse(String courseId) async {
    final result = await _service.getUnitsByCourse(courseId);
    return result.map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<String, List<TopicEntity>>> getTopicsByUnit(String unitId) async {
    final result = await _service.getTopicsByUnit(unitId);
    return result.map((list) => list.map((m) => m.toEntity()).toList());
  }
}
