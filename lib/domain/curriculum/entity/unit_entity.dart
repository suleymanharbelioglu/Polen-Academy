class UnitEntity {
  final String id;
  final String courseId;
  final String name;
  final int order;

  UnitEntity({
    required this.id,
    required this.courseId,
    required this.name,
    this.order = 0,
  });
}
