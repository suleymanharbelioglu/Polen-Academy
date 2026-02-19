import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/homework/model/homework_submission_model.dart';

abstract class HomeworkSubmissionFirebaseService {
  Future<Either<String, List<HomeworkSubmissionModel>>> getByHomeworkIdsAndStatus(
    List<String> homeworkIds,
    List<String> statuses,
  );
  Future<Either<String, HomeworkSubmissionModel?>> getByHomeworkAndStudent(
    String homeworkId,
    String studentId,
  );
  Future<Either<String, void>> set(HomeworkSubmissionModel submission);
}

class HomeworkSubmissionFirebaseServiceImpl extends HomeworkSubmissionFirebaseService {
  static const String _collection = 'HomeworkSubmissions';
  static const int _whereInLimit = 30;

  Map<String, dynamic> _docToMap(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = doc.id;
    for (final key in ['completedAt', 'updatedAt']) {
      if (data[key] is Timestamp) {
        data[key] = (data[key] as Timestamp).toDate().toIso8601String();
      }
    }
    return data;
  }

  Map<String, dynamic> _modelToFirestore(HomeworkSubmissionModel model) {
    final map = Map<String, dynamic>.from(model.toMap());
    map.remove('id');
    if (map['completedAt'] != null) {
      map['completedAt'] = Timestamp.fromDate(model.completedAt!);
    }
    map['updatedAt'] = Timestamp.fromDate(model.updatedAt);
    return map;
  }

  static String _docId(String homeworkId, String studentId) => '${homeworkId}_$studentId';

  @override
  Future<Either<String, List<HomeworkSubmissionModel>>> getByHomeworkIdsAndStatus(
    List<String> homeworkIds,
    List<String> statuses,
  ) async {
    if (homeworkIds.isEmpty) return const Right([]);
    try {
      final List<HomeworkSubmissionModel> all = [];
      for (var i = 0; i < homeworkIds.length; i += _whereInLimit) {
        final batch = homeworkIds.skip(i).take(_whereInLimit).toList();
        final snapshot = await FirebaseFirestore.instance
            .collection(_collection)
            .where('homeworkId', whereIn: batch)
            .get();
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final status = data['status'] as String? ?? 'pending';
          if (statuses.contains(status)) {
            final map = Map<String, dynamic>.from(data);
            map['id'] = doc.id;
            for (final key in ['completedAt', 'updatedAt']) {
              if (map[key] is Timestamp) {
                map[key] = (map[key] as Timestamp).toDate().toIso8601String();
              }
            }
            all.add(HomeworkSubmissionModel.fromMap(map));
          }
        }
      }
      return Right(all);
    } catch (e) {
      return Left('Ödev gönderimleri yüklenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, HomeworkSubmissionModel?>> getByHomeworkAndStudent(
    String homeworkId,
    String studentId,
  ) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(_docId(homeworkId, studentId))
          .get();
      if (doc.data() == null) return const Right(null);
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      for (final key in ['completedAt', 'updatedAt']) {
        if (data[key] is Timestamp) {
          data[key] = (data[key] as Timestamp).toDate().toIso8601String();
        }
      }
      return Right(HomeworkSubmissionModel.fromMap(data));
    } catch (e) {
      return Left('Ödev gönderimi yüklenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> set(HomeworkSubmissionModel submission) async {
    try {
      final id = _docId(submission.homeworkId, submission.studentId);
      final data = _modelToFirestore(submission);
      data['id'] = id;
      await FirebaseFirestore.instance.collection(_collection).doc(id).set(data, SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      return Left('Ödev gönderimi kaydedilirken hata: ${e.toString()}');
    }
  }
}
