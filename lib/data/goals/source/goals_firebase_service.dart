import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/goals/model/student_topic_progress_model.dart';

abstract class GoalsFirebaseService {
  Future<Either<String, List<StudentTopicProgressModel>>> getByStudent(
    String studentId,
  );
  Future<Either<String, void>> set(StudentTopicProgressModel model);
}

class GoalsFirebaseServiceImpl extends GoalsFirebaseService {
  static const String _collection = 'TopicProgress';

  @override
  Future<Either<String, List<StudentTopicProgressModel>>> getByStudent(
    String studentId,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .get();
      final list = snapshot.docs
          .map((doc) => StudentTopicProgressModel.fromMap(doc.data()))
          .toList();
      return Right(list);
    } catch (e) {
      return Left('İlerleme yüklenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> set(StudentTopicProgressModel model) async {
    try {
      final id = StudentTopicProgressModel.docId(model.studentId, model.topicId);
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id)
          .set(model.toMap(), SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      return Left('İlerleme güncellenirken hata: ${e.toString()}');
    }
  }
}
