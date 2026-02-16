import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/curriculum/model/course_model.dart';
import 'package:polen_academy/data/curriculum/model/topic_model.dart';
import 'package:polen_academy/data/curriculum/model/unit_model.dart';

abstract class CurriculumFirebaseService {
  Future<Either<String, List<CourseModel>>> getCoursesByClass(String classLevel);
  Future<Either<String, List<UnitModel>>> getUnitsByCourse(String courseId);
  Future<Either<String, List<TopicModel>>> getTopicsByUnit(String unitId);
}

class CurriculumFirebaseServiceImpl extends CurriculumFirebaseService {
  static const String _coursesCollection = 'CurriculumCourses';
  static const String _unitsCollection = 'CurriculumUnits';
  static const String _topicsCollection = 'CurriculumTopics';

  @override
  Future<Either<String, List<CourseModel>>> getCoursesByClass(String classLevel) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_coursesCollection)
          .where('classLevel', isEqualTo: classLevel)
          .get();
      final list = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return CourseModel.fromMap(data);
      }).toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return Right(list);
    } catch (e) {
      return Left('Dersler yüklenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<UnitModel>>> getUnitsByCourse(String courseId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_unitsCollection)
          .where('courseId', isEqualTo: courseId)
          .get();
      final list = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return UnitModel.fromMap(data);
      }).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return Right(list);
    } catch (e) {
      return Left('Üniteler yüklenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<TopicModel>>> getTopicsByUnit(String unitId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_topicsCollection)
          .where('unitId', isEqualTo: unitId)
          .get();
      final list = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return TopicModel.fromMap(data);
      }).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return Right(list);
    } catch (e) {
      return Left('Konular yüklenirken hata: ${e.toString()}');
    }
  }
}
