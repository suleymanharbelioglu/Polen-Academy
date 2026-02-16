class TopicEntity {
  final String id;
  final String unitId;
  final String name;
  final int order;

  TopicEntity({
    required this.id,
    required this.unitId,
    required this.name,
    this.order = 0,
  });
}
