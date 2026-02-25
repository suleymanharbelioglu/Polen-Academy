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
        if (courses.isEmpty) return Right(CurriculumTree(courses: []));
        // Tüm derslerin ünitelerini aynı anda çek
        final unitResults = await Future.wait(
          courses.map((c) => getUnitsByCourse(c.id)),
        );
        final courseWithUnits = <CourseWithUnits>[];
        for (var i = 0; i < courses.length; i++) {
          final units = unitResults[i].getOrElse(() => <UnitEntity>[]);
          units.sort((a, b) => a.order.compareTo(b.order));
          final unitIds = units.map((u) => u.id).toList();
          if (unitIds.isEmpty) {
            courseWithUnits.add(CourseWithUnits(course: courses[i], units: []));
            continue;
          }
          // Bu dersin tüm ünitelerinin konularını aynı anda çek
          final topicResults = await Future.wait(
            unitIds.map((id) => getTopicsByUnit(id)),
          );
          final unitWithTopics = <UnitWithTopics>[];
          for (var j = 0; j < units.length; j++) {
            final topics = topicResults[j].getOrElse(() => <TopicEntity>[]);
            topics.sort((a, b) => a.order.compareTo(b.order));
            unitWithTopics.add(UnitWithTopics(unit: units[j], topics: topics));
          }
          courseWithUnits.add(CourseWithUnits(course: courses[i], units: unitWithTopics));
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
