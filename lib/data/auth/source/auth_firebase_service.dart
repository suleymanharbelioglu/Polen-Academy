import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:polen_academy/data/auth/model/coach.dart';
import 'package:polen_academy/data/auth/model/coach_signin_req.dart';
import 'package:polen_academy/data/auth/model/parent.dart';
import 'package:polen_academy/data/auth/model/parent_creation_result.dart';
import 'package:polen_academy/data/auth/model/parent_signin_req.dart';
import 'package:polen_academy/data/auth/model/student.dart';
import 'package:polen_academy/data/auth/model/student_creation_result.dart';
import 'package:polen_academy/data/auth/model/student_signin_req.dart';

abstract class AuthFirebaseService {
  Future<Either> coachSignup(CoachModel coach);
  Future<Either> coachSignin(CoachSigninReq req);
  Future<Either> studentSignup(StudentModel student);
  Future<Either> studentSignin(StudentSigninReq req);
  Future<Either> parentSignup(ParentModel parent);
  Future<Either> parentSignin(ParentSigninReq req);
  Future<Either> signOut();
  bool isLoggedIn();
  String? getCurrentUserUid();

  /// Returns the current user's role from Firestore (e.g. 'coach', 'student', 'parent') or null.
  Future<String?> getCurrentUserRole();
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  @override
  Future<Either> coachSignup(CoachModel coach) async {
    try {
      final password = coach.password ?? '';
      if (password.isEmpty) {
        return const Left('Şifre gerekli');
      }
      // Firebase Authentication ile kullanıcı oluştur
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: coach.email,
            password: password,
          );

      // Kullanıcının UID'sini al
      final String uid = userCredential.user!.uid;

      // Firestore'a kullanıcı bilgilerini kaydet
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .set(
            CoachModel(
              uid: uid,
              firstName: coach.firstName,
              lastName: coach.lastName,
              email: coach.email,
              role: 'coach',
            ).toMap(),
          );

      return Right(userCredential.user);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Kayıt sırasında bir hata oluştu';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Bu e-posta adresi zaten kullanılıyor';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi';
          break;
        case 'operation-not-allowed':
          errorMessage = 'E-posta/şifre girişi etkin değil';
          break;
        case 'weak-password':
          errorMessage = 'Şifre çok zayıf';
          break;
      }

      return Left(errorMessage);
    } catch (e) {
      return Left('Beklenmeyen bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<Either> coachSignin(CoachSigninReq req) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: req.email, password: req.password);

      return Right(userCredential.user);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Giriş sırasında bir hata oluştu';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Bu e-posta ile kayıtlı kullanıcı bulunamadı';
          break;
        case 'wrong-password':
          errorMessage = 'Hatalı şifre';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi';
          break;
        case 'user-disabled':
          errorMessage = 'Bu hesap devre dışı bırakılmış';
          break;
        case 'invalid-credential':
          errorMessage = 'E-posta veya şifre hatalı';
          break;
      }

      return Left(errorMessage);
    } catch (e) {
      return Left('Beklenmeyen bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<Either> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      return const Right('Çıkış başarılı');
    } catch (e) {
      return Left('Çıkış yapılırken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  String? getCurrentUserUid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Future<String?> getCurrentUserRole() async {
    final uid = getCurrentUserUid();
    if (uid == null) return null;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();
      return doc.data()?['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Cloud Functions region. Must match where createStudent is deployed.
  /// Default Firebase region is us-central1. If you deployed with e.g. europe-west1, change this.
  static const String _functionsRegion = 'us-central1';

  @override
  Future<Either> studentSignup(StudentModel student) async {
    try {
      // Use the same region as your deployed Cloud Function.
      final functions = FirebaseFunctions.instanceFor(region: _functionsRegion);
      final callable = functions.httpsCallable(
        'createStudent',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );
      final result = await callable.call<Map<String, dynamic>>(student.toMap());

      final data = result.data;
      final email = data['email'] as String? ?? '';
      final password = data['password'] as String? ?? '';

      return Right(StudentCreationResult(email: email, password: password));
    } on FirebaseFunctionsException catch (e) {
      String message = e.message ?? 'Öğrenci kaydı sırasında bir hata oluştu';
      switch (e.code) {
        case 'unauthenticated':
          message = 'Oturum açmanız gerekir. Lütfen tekrar giriş yapın.';
          break;
        case 'permission-denied':
          message = 'Sadece koçlar öğrenci ekleyebilir.';
          break;
        case 'unavailable':
        case 'resource-exhausted':
        case 'deadline-exceeded':
          message =
              'Sunucuya ulaşılamıyor. İnternet bağlantınızı kontrol edin veya daha sonra tekrar deneyin.';
          break;
        case 'not-found':
          message =
              'createStudent fonksiyonu bulunamadı. Cloud Function bölgesi: $_functionsRegion.';
          break;
      }
      return Left(message);
    } catch (e) {
      return Left('Bağlantı hatası: ${e.toString()}');
    }
  }

  @override
  Future<Either> studentSignin(StudentSigninReq req) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: req.email, password: req.password);

      return Right(userCredential.user);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Giriş sırasında bir hata oluştu';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Bu e-posta ile kayıtlı kullanıcı bulunamadı';
          break;
        case 'wrong-password':
          errorMessage = 'Hatalı şifre';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi';
          break;
        case 'user-disabled':
          errorMessage = 'Bu hesap devre dışı bırakılmış';
          break;
        case 'invalid-credential':
          errorMessage = 'E-posta veya şifre hatalı';
          break;
      }

      return Left(errorMessage);
    } catch (e) {
      return Left('Beklenmeyen bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<Either> parentSignup(ParentModel parent) async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: _functionsRegion);
      final callable = functions.httpsCallable(
        'createParent',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );
      final result = await callable.call<Map<String, dynamic>>(parent.toMap());

      final data = result.data;
      final email = data['email'] as String? ?? '';
      final password = data['password'] as String? ?? '';
      final uid = data['uid'] as String? ?? '';

      return Right(
        ParentCreationResult(email: email, password: password, uid: uid),
      );
    } on FirebaseFunctionsException catch (e) {
      String message = e.message ?? 'Veli kaydı sırasında bir hata oluştu';
      switch (e.code) {
        case 'unauthenticated':
          message = 'Oturum açmanız gerekir. Lütfen tekrar giriş yapın.';
          break;
        case 'permission-denied':
          message = 'Sadece koçlar veli ekleyebilir.';
          break;
        case 'unavailable':
        case 'resource-exhausted':
        case 'deadline-exceeded':
          message =
              'Sunucuya ulaşılamıyor. İnternet bağlantınızı kontrol edin veya daha sonra tekrar deneyin.';
          break;
        case 'not-found':
          message =
              'createParent fonksiyonu bulunamadı. Cloud Function bölgesi: $_functionsRegion.';
          break;
      }
      return Left(message);
    } catch (e) {
      return Left('Bağlantı hatası: ${e.toString()}');
    }
  }

  @override
  Future<Either> parentSignin(ParentSigninReq req) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: req.email, password: req.password);

      return Right(userCredential.user);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Giriş sırasında bir hata oluştu';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Bu e-posta ile kayıtlı kullanıcı bulunamadı';
          break;
        case 'wrong-password':
          errorMessage = 'Hatalı şifre';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi';
          break;
        case 'user-disabled':
          errorMessage = 'Bu hesap devre dışı bırakılmış';
          break;
        case 'invalid-credential':
          errorMessage = 'E-posta veya şifre hatalı';
          break;
      }

      return Left(errorMessage);
    } catch (e) {
      return Left('Beklenmeyen bir hata oluştu: ${e.toString()}');
    }
  }
}
