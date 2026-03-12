import 'package:flutter/material.dart';
import 'package:polen_academy/domain/homework/entity/homework_entity.dart';
import 'package:polen_academy/domain/homework/entity/homework_submission_entity.dart';

/// Ödev listeleme: renk, durum, sıra, tür etiketi. UI'da logic yok, sadece bu helper.
class HomeworkUiHelper {
  HomeworkUiHelper._();

  static Color colorForStatus(HomeworkSubmissionStatus s) {
    switch (s) {
      case HomeworkSubmissionStatus.approved:
        return const Color(0xFF4CAF50);
      case HomeworkSubmissionStatus.completedByStudent:
        return Colors.blue;
      case HomeworkSubmissionStatus.missing:
        return Colors.amber;
      case HomeworkSubmissionStatus.notDone:
        return Colors.deepOrange;
      case HomeworkSubmissionStatus.pending:
        return Colors.grey;
    }
  }

  /// Kart/liste için gösterim durumu: submission varsa onun statusu, yoksa süreye göre.
  static HomeworkSubmissionStatus displayStatus(
    HomeworkEntity homework,
    HomeworkSubmissionEntity? submission,
  ) {
    if (submission != null) return submission.status;
    final today = _today();
    final endDay = DateTime(
      homework.endDate.year,
      homework.endDate.month,
      homework.endDate.day,
    );
    if (endDay.isBefore(today)) return HomeworkSubmissionStatus.notDone;
    return HomeworkSubmissionStatus.pending;
  }

  /// Sıralama için sayı (küçük önce).
  static int statusSortOrder(HomeworkSubmissionStatus s) {
    switch (s) {
      case HomeworkSubmissionStatus.approved:
        return 0;
      case HomeworkSubmissionStatus.completedByStudent:
        return 1;
      case HomeworkSubmissionStatus.pending:
        return 2;
      case HomeworkSubmissionStatus.missing:
        return 3;
      case HomeworkSubmissionStatus.notDone:
        return 4;
    }
  }

  /// Ödev türü etiketi.
  static String typeLabel(HomeworkType type) {
    switch (type) {
      case HomeworkType.topicBased:
        return 'Konu bazlı';
      case HomeworkType.freeText:
        return 'Serbest metin';
      case HomeworkType.routine:
        return 'Rutin';
    }
  }

  /// Listeyi sekme gösterimi için sıralar (durum, sonra tarih).
  static List<HomeworkEntity> sortForDisplay(
    List<HomeworkEntity> list,
    Map<String, HomeworkSubmissionEntity> submissionByHomeworkId,
  ) {
    final sorted = List<HomeworkEntity>.from(list);
    sorted.sort((a, b) {
      final statusA = displayStatus(a, submissionByHomeworkId[a.id]);
      final statusB = displayStatus(b, submissionByHomeworkId[b.id]);
      final order = statusSortOrder(statusA).compareTo(statusSortOrder(statusB));
      if (order != 0) return order;
      final da = a.assignedDate ?? a.createdAt;
      final db = b.assignedDate ?? b.createdAt;
      return db.compareTo(da);
    });
    return sorted;
  }

  /// Sıralı liste + her ödev için gösterim durumu (sekme listesi için).
  static List<(HomeworkEntity, HomeworkSubmissionStatus)> sortedItems(
    List<HomeworkEntity> list,
    Map<String, HomeworkSubmissionEntity> submissionByHomeworkId,
  ) {
    final sorted = sortForDisplay(list, submissionByHomeworkId);
    return sorted
        .map((h) => (h, displayStatus(h, submissionByHomeworkId[h.id])))
        .toList();
  }

  static List<HomeworkEntity> filterCompleted(
    List<HomeworkEntity> list,
    Map<String, HomeworkSubmissionEntity> map,
  ) =>
      list.where((h) => _completed(map[h.id])).toList();

  static List<HomeworkEntity> filterOverdue(
    List<HomeworkEntity> list,
    Map<String, HomeworkSubmissionEntity> map,
  ) {
    final today = _today();
    return list.where((h) {
      final sub = map[h.id];
      final endDay = DateTime(h.endDate.year, h.endDate.month, h.endDate.day);
      if (!endDay.isBefore(today)) return false;
      return sub == null || sub.status == HomeworkSubmissionStatus.pending;
    }).toList();
  }

  static List<HomeworkEntity> filterMissing(
    List<HomeworkEntity> list,
    Map<String, HomeworkSubmissionEntity> map,
  ) =>
      list.where((h) => map[h.id]?.status == HomeworkSubmissionStatus.missing).toList();

  static List<HomeworkEntity> filterNotDone(
    List<HomeworkEntity> list,
    Map<String, HomeworkSubmissionEntity> map,
  ) =>
      list.where((h) => map[h.id]?.status == HomeworkSubmissionStatus.notDone).toList();

  static bool _completed(HomeworkSubmissionEntity? sub) =>
      sub != null && sub.isCompleted;

  static String formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
