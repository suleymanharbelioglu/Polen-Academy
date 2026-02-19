import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:polen_academy/core/constants/app_urls.dart';

/// Ödev dosyalarını Firebase Storage'a yükler (HomeworkFiles/{coachId}/).
abstract class HomeworkStorageService {
  Future<Either<String, String>> uploadFile({
    required String filePath,
    required String coachId,
  });
}

class HomeworkStorageServiceImpl extends HomeworkStorageService {
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  @override
  Future<Either<String, String>> uploadFile({
    required String filePath,
    required String coachId,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const Left('Dosya bulunamadı.');
      }
      final length = await file.length();
      if (length > _maxFileSizeBytes) {
        return const Left('Dosya en fazla 5MB olabilir.');
      }
      final name = filePath.split(RegExp(r'[/\\]')).last;
      final sanitized = name.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
      final storagePath =
          '${AppUrl.homeworkFilesStoragePath}/$coachId/${DateTime.now().millisecondsSinceEpoch}_$sanitized';
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left('Yükleme hatası: ${e.message ?? e.code}');
    } catch (e) {
      return Left('Dosya yüklenirken hata: $e');
    }
  }
}
