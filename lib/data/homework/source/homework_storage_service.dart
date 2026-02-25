import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:polen_academy/core/constants/app_urls.dart';

/// Ödev dosyalarını Firebase Storage'a yükler (HomeworkFiles/{studentId}/).
abstract class HomeworkStorageService {
  Future<Either<String, String>> uploadFile({
    required String filePath,
    required String studentId,
  });

  /// Android vb. ortamlarda path null olduğunda bytes ile yükleme.
  Future<Either<String, String>> uploadFileFromBytes({
    required String studentId,
    required Uint8List bytes,
    required String fileName,
  });
}

class HomeworkStorageServiceImpl extends HomeworkStorageService {
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  @override
  Future<Either<String, String>> uploadFile({
    required String filePath,
    required String studentId,
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
          '${AppUrl.homeworkFilesStoragePath}/$studentId/${DateTime.now().millisecondsSinceEpoch}_$sanitized';
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

  @override
  Future<Either<String, String>> uploadFileFromBytes({
    required String studentId,
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      if (bytes.length > _maxFileSizeBytes) {
        return const Left('Dosya en fazla 5MB olabilir.');
      }
      final sanitized = fileName.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
      final storagePath =
          '${AppUrl.homeworkFilesStoragePath}/$studentId/${DateTime.now().millisecondsSinceEpoch}_$sanitized';
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      await ref.putData(bytes as dynamic);
      final downloadUrl = await ref.getDownloadURL();
      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left('Yükleme hatası: ${e.message ?? e.code}');
    } catch (e) {
      return Left('Dosya yüklenirken hata: $e');
    }
  }
}
