import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/homework/source/homework_storage_service.dart';
import 'package:polen_academy/service_locator.dart';

/// Ödev dosyasını Storage'a yükler, indirme URL'sini döner. Path: HomeworkFiles/{studentId}/...
class UploadHomeworkFileUseCase {
  /// Dosya yolundan yükle (koç tarafı veya path mevcut olduğunda).
  Future<Either<String, String>> call({
    required String filePath,
    required String studentId,
  }) {
    return sl<HomeworkStorageService>().uploadFile(
      filePath: filePath,
      studentId: studentId,
    );
  }

  /// Byte listesinden yükle (Android'de path null olduğunda öğrenci resim eklerken).
  Future<Either<String, String>> fromBytes({
    required String studentId,
    required Uint8List bytes,
    required String fileName,
  }) {
    return sl<HomeworkStorageService>().uploadFileFromBytes(
      studentId: studentId,
      bytes: bytes,
      fileName: fileName,
    );
  }
}
