import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/session/model/session.dart';

abstract class SessionFirebaseService {
  Future<Either<String, List<SessionModel>>> getByCoachAndDateRange(
    String coachId,
    DateTime start,
    DateTime end,
  );
  Future<Either<String, List<SessionModel>>> getByCoachAndDate(
    String coachId,
    DateTime date,
  );
  Future<Either<String, SessionModel>> create(SessionModel session);
  Future<Either<String, void>> update(SessionModel session);
  Future<Either<String, void>> delete(String sessionId);
  Future<Either<String, void>> updateStatus(String sessionId, String status);
}

class SessionFirebaseServiceImpl extends SessionFirebaseService {
  static const String _collection = 'Sessions';

  Map<String, dynamic> _docToMap(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = doc.id;
    final date = data['date'];
    final createdAt = data['createdAt'];
    if (date is Timestamp) data['date'] = date.toDate().toIso8601String();
    if (createdAt is Timestamp) data['createdAt'] = createdAt.toDate().toIso8601String();
    return data;
  }

  Map<String, dynamic> _modelToFirestore(SessionModel model) {
    final map = model.toMap();
    map['date'] = Timestamp.fromDate(model.date);
    map['createdAt'] = Timestamp.fromDate(model.createdAt);
    map.remove('id');
    return map;
  }

  @override
  Future<Either<String, List<SessionModel>>> getByCoachAndDateRange(
    String coachId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final startAt = DateTime(start.year, start.month, start.day);
      final endAt = DateTime(end.year, end.month, end.day, 23, 59, 59);
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('coachId', isEqualTo: coachId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startAt))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endAt))
          .orderBy('date')
          .orderBy('startTime')
          .get();

      final list = snapshot.docs
          .map((doc) => SessionModel.fromMap(_docToMap(doc)))
          .toList();
      return Right(list);
    } catch (e) {
      return Left('Seanslar yüklenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<SessionModel>>> getByCoachAndDate(
    String coachId,
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return getByCoachAndDateRange(coachId, start, end);
  }

  @override
  Future<Either<String, SessionModel>> create(SessionModel session) async {
    try {
      final ref = FirebaseFirestore.instance.collection(_collection).doc();
      final data = _modelToFirestore(session);
      await ref.set({...data, 'id': ref.id});
      final created = SessionModel(
        id: ref.id,
        coachId: session.coachId,
        studentId: session.studentId,
        studentName: session.studentName,
        date: session.date,
        startTime: session.startTime,
        endTime: session.endTime,
        isWeeklyRecurring: session.isWeeklyRecurring,
        noteChips: session.noteChips,
        noteText: session.noteText,
        status: session.status,
        createdAt: session.createdAt,
      );
      return Right(created);
    } catch (e) {
      return Left('Seans oluşturulurken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> update(SessionModel session) async {
    try {
      if (session.id.isEmpty) return const Left('Seans id gerekli');
      final ref = FirebaseFirestore.instance.collection(_collection).doc(session.id);
      final data = _modelToFirestore(session);
      await ref.update(data);
      return const Right(null);
    } catch (e) {
      return Left('Seans güncellenirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> delete(String sessionId) async {
    try {
      if (sessionId.isEmpty) return const Left('Seans id gerekli');
      await FirebaseFirestore.instance.collection(_collection).doc(sessionId).delete();
      return const Right(null);
    } catch (e) {
      return Left('Seans silinirken hata: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateStatus(String sessionId, String status) async {
    try {
      if (sessionId.isEmpty) return const Left('Seans id gerekli');
      await FirebaseFirestore.instance.collection(_collection).doc(sessionId).update({'status': status});
      return const Right(null);
    } catch (e) {
      return Left('Durum güncellenirken hata: ${e.toString()}');
    }
  }
}
