import 'package:polen_academy/domain/curriculum/entity/unit_entity.dart';

class UnitModel {
  final String id;
  final String courseId;
  final String name;
  final int order;

  UnitModel({
    required this.id,
    required this.courseId,
    required this.name,
    this.order = 0,
  });

  factory UnitModel.fromMap(Map<String, dynamic> map) {
    return UnitModel(
      id: map['id'] ?? '',
      courseId: map['courseId'] ?? '',
      name: map['name'] ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'name': name,
      'order': order,
    };
  }

  UnitEntity toEntity() => UnitEntity(
        id: id,
        courseId: courseId,
        name: name,
        order: order,
      );
}
