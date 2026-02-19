import 'package:dartz/dartz.dart';
import 'package:polen_academy/data/homework/source/homework_storage_service.dart';
import 'package:polen_academy/service_locator.dart';

/// Ödev dosyasını Storage'a yükler, indirme URL'sini döner.
class UploadHomeworkFileUseCase {
  Future<Either<String, String>> call({
    required String filePath,
    required String coachId,
  }) {
    return sl<HomeworkStorageService>().uploadFile(
      filePath: filePath,
      coachId: coachId,
    );
  }
}
