/// Konu ve Tekrar kutuları için durum: sadece ilgili kutu bu renge bürünür.
enum TopicStatus {
  none,
  completed,
  notDone,
  incomplete;

  static TopicStatus fromString(String? s) {
    switch (s) {
      case 'completed':
        return TopicStatus.completed;
      case 'not_done':
        return TopicStatus.notDone;
      case 'incomplete':
        return TopicStatus.incomplete;
      default:
        return TopicStatus.none;
    }
  }
}

extension TopicStatusX on TopicStatus {
  String get value {
    switch (this) {
      case TopicStatus.none:
        return 'none';
      case TopicStatus.completed:
        return 'completed';
      case TopicStatus.notDone:
        return 'not_done';
      case TopicStatus.incomplete:
        return 'incomplete';
    }
  }
}
