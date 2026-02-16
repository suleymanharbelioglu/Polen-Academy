import 'package:polen_academy/domain/curriculum/entity/topic_entity.dart';

class TopicModel {
  final String id;
  final String unitId;
  final String name;
  final int order;

  TopicModel({
    required this.id,
    required this.unitId,
    required this.name,
    this.order = 0,
  });

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id'] ?? '',
      unitId: map['unitId'] ?? '',
      name: map['name'] ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unitId': unitId,
      'name': name,
      'order': order,
    };
  }

  TopicEntity toEntity() => TopicEntity(
        id: id,
        unitId: unitId,
        name: name,
        order: order,
      );
}
