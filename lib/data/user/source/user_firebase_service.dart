import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/user/model/student.dart';

abstract class UserFirebaseService {
  Future<Either<String, List<Map<String, dynamic>>>> getMyStudents(
    String coachId,
  );
  Future<Either<String, Map<String, dynamic>?>> getStudentByUid(String uid);
  Future<Either<String, Map<String, dynamic>?>> getStudentByParentId(String parentId);
  Future<Either<String, void>> deleteStudent(String studentId);
  Future<Either<String, void>> updateUserPassword(String userId, String newPassword);
}

class UserFirebaseServiceImpl extends UserFirebaseService {
  static const String _functionsRegion = 'us-central1';

  @override
  Future<Either<String, List<Map<String, dynamic>>>> getMyStudents(
    String coachId,
  ) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'student')
          .where('coachId', isEqualTo: coachId)
          .get();

      final students = querySnapshot.docs.map((doc) {
        return StudentModel.fromMap({...doc.data(), 'uid': doc.id}).toMap();
      }).toList();

      return Right(students);
    } catch (e) {
      return Left('Öğrenciler yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>?>> getStudentByUid(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return const Right(null);
      return Right({...doc.data()!, 'uid': doc.id});
    } catch (e) {
      return Left('Öğrenci bilgisi yüklenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>?>> getStudentByParentId(String parentId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'student')
          .where('parentId', isEqualTo: parentId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) return const Right(null);
      final doc = querySnapshot.docs.first;
      return Right({...doc.data(), 'uid': doc.id});
    } catch (e) {
      return Left('Öğrenci bilgisi yüklenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteStudent(String studentId) async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: _functionsRegion);
      final callable = functions.httpsCallable(
        'deleteStudent',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );
      await callable.call<Map<String, dynamic>>({'studentId': studentId});
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      final message = e.message ?? 'Öğrenci silinirken hata oluştu';
      return Left(message);
    } catch (e) {
      return Left('Öğrenci silinirken hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateUserPassword(String userId, String newPassword) async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: _functionsRegion);
      final callable = functions.httpsCallable(
        'updateUserPassword',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );
      await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'newPassword': newPassword,
      });
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      final message = e.message ?? 'Şifre güncellenirken hata oluştu';
      return Left(message);
    } catch (e) {
      return Left('Şifre güncellenirken hata oluştu: ${e.toString()}');
    }
  }
}
