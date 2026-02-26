import 'package:polen_academy/domain/notification/entity/notification_entity.dart';

class NotificationModel {
  final String id;
  final String type;
  final String recipientUserId;
  final String title;
  final String body;
  final String? relatedId;
  final String? relatedId2;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.recipientUserId,
    required this.title,
    required this.body,
    this.relatedId,
    this.relatedId2,
    required this.createdAt,
    this.readAt,
  });

  static NotificationType _typeFromString(String? v) {
    if (v == null) return NotificationType.sessionPlanned;
    return NotificationType.values.firstWhere(
      (e) => e.name == v,
      orElse: () => NotificationType.sessionPlanned,
    );
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    final readAt = map['readAt'];
    return NotificationModel(
      id: map['id'] ?? '',
      type: map['type'] as String? ?? 'sessionPlanned',
      recipientUserId: map['recipientUserId'] ?? map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      relatedId: map['relatedId'] as String?,
      relatedId2: map['relatedId2'] as String?,
      createdAt: _parseDateTime(createdAt),
      readAt: readAt != null ? _parseDateTime(readAt) : null,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value.toString());
    return parsed ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'recipientUserId': recipientUserId,
      'type': type,
      'title': title,
      'body': body,
      if (relatedId != null) 'relatedId': relatedId,
      if (relatedId2 != null) 'relatedId2': relatedId2,
      'createdAt': createdAt,
      if (readAt != null) 'readAt': readAt,
    };
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: _typeFromString(type),
      recipientUserId: recipientUserId,
      title: title,
      body: body,
      relatedId: relatedId,
      relatedId2: relatedId2,
      createdAt: createdAt,
      readAt: readAt,
    );
  }

  static NotificationModel fromEntity(NotificationEntity e) {
    return NotificationModel(
      id: e.id,
      type: e.type.name,
      recipientUserId: e.recipientUserId,
      title: e.title,
      body: e.body,
      relatedId: e.relatedId,
      relatedId2: e.relatedId2,
      createdAt: e.createdAt,
      readAt: e.readAt,
    );
  }
}
