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

  /// Sends password reset email to the given address. Returns Left(error) or Right(null).
  Future<Either<String, void>> sendPasswordResetEmail(String email);

  /// Returns the current user's role from Firestore (e.g. 'coach', 'student', 'parent') or null.
  Future<String?> getCurrentUserRole();

  /// Returns the current coach's first name from Firestore, or null if not coach or not found.
  Future<String?> getCurrentCoachFirstName();

  /// Returns current user's display info (firstName, lastName, role) from Firestore. One read.
  /// Keys: firstName, lastName, role. Returns null if not found.
  Future<Map<String, String>?> getCurrentUserDisplayInfo();

  /// Deletes current user: Firestore Users doc then Firebase Auth user. Returns Left(error) or Right(null).
  Future<Either<String, void>> deleteCurrentUserAccount();

  /// Veli dokümanından ad soyad (öğrenci drawer'da "Velisi: ..." için).
  Future<String> getParentDisplayName(String parentId);
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
  Future<Either<String, void>> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      String message = 'Şifre sıfırlama e-postası gönderilemedi';
      switch (e.code) {
        case 'user-not-found':
          message = 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı';
          break;
        case 'invalid-email':
          message = 'Geçersiz e-posta adresi';
          break;
        case 'too-many-requests':
          message = 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin';
          break;
      }
      return Left(message);
    } catch (e) {
      return Left('Beklenmeyen hata: ${e.toString()}');
    }
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

  @override
  Future<String?> getCurrentCoachFirstName() async {
    final info = await getCurrentUserDisplayInfo();
    return info?['firstName'];
  }

  @override
  Future<Map<String, String>?> getCurrentUserDisplayInfo() async {
    final uid = getCurrentUserUid();
    if (uid == null) return null;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();
      final data = doc.data();
      if (data == null) return null;
      final role = (data['role'] as String? ?? '').toString();
      String firstName;
      String lastName;
      if (role == 'student') {
        firstName = (data['studentName'] as String? ?? '').toString();
        lastName = (data['studentSurname'] as String? ?? '').toString();
      } else if (role == 'parent') {
        firstName = (data['parentName'] as String? ?? '').toString();
        lastName = (data['parentSurname'] as String? ?? '').toString();
      } else {
        firstName = (data['firstName'] as String? ?? '').toString();
        lastName = (data['lastName'] as String? ?? '').toString();
      }
      return {
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      };
    } catch (_) {
      return null;
    }
  }

  /// Returns parent display name for a given parent uid (e.g. "Ad Soyad").
  Future<String> getParentDisplayName(String parentId) async {
    if (parentId.isEmpty) return '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(parentId)
          .get();
      final data = doc.data();
      if (data == null) return '';
      final name = (data['parentName'] as String? ?? '').toString().trim();
      final surname = (data['parentSurname'] as String? ?? '').toString().trim();
      return [name, surname].where((s) => s.isNotEmpty).join(' ').trim();
    } catch (_) {
      return '';
    }
  }

  @override
  Future<Either<String, void>> deleteCurrentUserAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Left('Oturum bulunamadı');
    final uid = user.uid;
    try {
      await FirebaseFirestore.instance.collection('Users').doc(uid).delete();
      await user.delete();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      String message = 'Hesap silinirken bir hata oluştu';
      if (e.code == 'requires-recent-login') {
        message = 'Güvenlik için lütfen çıkış yapıp tekrar giriş yapın, ardından hesabınızı silmeyi deneyin.';
      }
      return Left(message);
    } catch (e) {
      return Left('Hesap silinirken hata: ${e.toString()}');
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
