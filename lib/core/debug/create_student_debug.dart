import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:polen_academy/core/debug/app_debug_log.dart';
import 'package:polen_academy/core/debug/auth_debug.dart';

/// Öğrenci ekleme auth / Cloud Function sorunlarını terminalde izlemek için.
class CreateStudentDebug {
  CreateStudentDebug._();

  static const String tag = '[CREATE_STUDENT]';

  static void log(String message) {
    AppDebugLog.line('CREATE_STUDENT', message);
  }

  static void section(String title) {
    AppDebugLog.block('CREATE_STUDENT', '$tag ══════════ $title ══════════');
  }

  static Future<void> logAuthSnapshot(String step) async {
    await AuthDebug.log(context: 'Öğrenci ekleme — $step');
  }

  static Future<void> logCoachRole(String coachUid) async {
    section('FIRESTORE — Koç rolü');
    log('coachUid: $coachUid');
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(coachUid)
          .get();
      log('Users/$coachUid exists: ${doc.exists}');
      if (doc.exists) {
        final data = doc.data();
        log('role: ${data?['role']}');
        log('email: ${data?['email'] ?? data?['firstName']}');
      } else {
        log('Users dokümanı bulunamadı — permission-denied veya rol hatası olabilir');
      }
    } catch (e, st) {
      log('Firestore okuma HATA: $e');
      log('Stack: $st');
    }
  }

  static void logPayload(Map<String, dynamic> payload) {
    section('createStudent payload');
    log('studentName: ${payload['studentName']}');
    log('studentSurname: ${payload['studentSurname']}');
    log('studentClass: ${payload['studentClass']}');
    log('coachId: ${payload['coachId']}');
    log('focusCourseIds: ${payload['focusCourseIds']}');
    log('academicField: ${payload['academicField']}');
  }

  static void logCallableConfig({
    required String region,
    required String functionName,
  }) {
    section('Cloud Function config');
    log('region: $region');
    log('functionName: $functionName');
    try {
      final projectId = 'polen-akademi';
      log('beklenen URL: https://$region-$projectId.cloudfunctions.net/$functionName');
    } catch (e) {
      log('URL oluşturulamadı: $e');
    }
  }

  static void logFunctionsException(FirebaseFunctionsException e) {
    section('FirebaseFunctionsException');
    log('code: ${e.code}');
    log('message: ${e.message}');
    log('details: ${e.details}');
    log('plugin: ${e.plugin}');
    if (e.stackTrace != null) {
      log('stackTrace: ${e.stackTrace}');
    }
    if (e.code == 'unauthenticated') {
      log(
        '→ Olası nedenler: App Check enforcement (debug token Console\'da kayıtlı mı?), '
        'context.auth yok, veya eski auth oturumu',
      );
    }
  }

  static void logGenericError(Object e, StackTrace st) {
    section('Genel HATA');
    log('type: ${e.runtimeType}');
    log('message: $e');
    log('stackTrace: $st');
  }
}
