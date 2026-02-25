import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/homework/model/homework_model.dart';

abstract class HomeworkFirebaseService {
  Future<Either<String, List<HomeworkModel>>> getByStudentAndDateRange(
    String studentId,
    DateTime start,
    DateTime end,
  );
  Future<Either<String, List<HomeworkModel>>> getByCoachId(String coachId);
  Future<Either<String, HomeworkModel?>> getById(String homeworkId);
  Future<Either<String, HomeworkModel>> create(HomeworkModel homework);
  Future<Either<String, void>> delete(String homeworkId);
}

class HomeworkFirebaseServiceImpl extends HomeworkFirebaseService {
  static const String _collection = 'Homeworks';

  Map<String, dynamic> _docToMap(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = doc.id;
    for (final key in ['startDate', 'endDate', 'assignedDate', 'createdAt']) {
      if (data[key] is Timestamp) {
        data[key] = (data[key] as Timestamp).toDate().toIso8601String();
      }
    }
    return data;
  }

  Map<String, dynamic> _modelToFirestore(HomeworkModel model) {
    final map = Map<String, dynamic>.from(model.toMap());
    map.remove('id');
    if (map['startDate'] != null) {
      map['startDate'] = Timestamp.fromDate(model.startDate!);
    }
    map['endDate'] = Timestamp.fromDate(model.endDate);
    if (map['assignedDate'] != null) {
      map['assignedDate'] = Timestamp.fromDate(model.assignedDate!);
    }
    map['createdAt'] = Timestamp.fromDate(model.createdAt);
    return map;
  }

  @override
  Future<Either<String, List<HomeworkModel>>> getByStudentAndDateRange(
    String studentId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final startAt = DateTime(start.year, start.month, start.day);
      final endAt = DateTime(end.year, end.month, end.day, 23, 59, 59);
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startAt))
          .orderBy('endDate')
          .get();

      final list = snapshot.docs
          .map((doc) => HomeworkModel.fromMap(_docToMap(doc)))
          .where((m) {
        final effectiveStart = m.startDate ?? m.endDate;
        return !effectiveStart.isAfter(endAt);
      })
          .toList();
      return Right(list);
    } catch (e) {
      return Left('Ödevler yüklenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<HomeworkModel>>> getByCoachId(String coachId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('coachId', isEqualTo: coachId)
          .orderBy('createdAt', descending: true)
          .get();
      final list = snapshot.docs.map((doc) => HomeworkModel.fromMap(_docToMap(doc))).toList();
      return Right(list);
    } catch (e) {
      return Left('Ödevler yüklenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, HomeworkModel?>> getById(String homeworkId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection(_collection).doc(homeworkId).get();
      if (doc.data() == null) return const Right(null);
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      for (final key in ['startDate', 'endDate', 'assignedDate', 'createdAt']) {
        if (data[key] is Timestamp) {
          data[key] = (data[key] as Timestamp).toDate().toIso8601String();
        }
      }
      return Right(HomeworkModel.fromMap(data));
    } catch (e) {
      return Left('Ödev yüklenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, HomeworkModel>> create(HomeworkModel homework) async {
    try {
      final ref = FirebaseFirestore.instance.collection(_collection).doc();
      final data = _modelToFirestore(homework);
      await ref.set(data);
      final created = HomeworkModel(
        id: ref.id,
        coachId: homework.coachId,
        studentId: homework.studentId,
        type: homework.type,
        startDate: homework.startDate,
        endDate: homework.endDate,
        assignedDate: homework.assignedDate,
        optionalTime: homework.optionalTime,
        courseId: homework.courseId,
        courseName: homework.courseName,
        topicIds: homework.topicIds,
        topicNames: homework.topicNames,
        description: homework.description,
        links: homework.links,
        youtubeUrls: homework.youtubeUrls,
        fileUrls: homework.fileUrls,
        goalKonuStudied: homework.goalKonuStudied,
        goalRevisionDone: homework.goalRevisionDone,
        goalResourceSolve: homework.goalResourceSolve,
        routineInterval: homework.routineInterval,
        createdAt: homework.createdAt,
      );
      return Right(created);
    } catch (e) {
      return Left('Ödev eklenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> delete(String homeworkId) async {
    try {
      await FirebaseFirestore.instance.collection(_collection).doc(homeworkId).delete();
      return const Right(null);
    } catch (e) {
      return Left('Ödev silinirken hata: ${e.toString()}');
    }
  }
}
