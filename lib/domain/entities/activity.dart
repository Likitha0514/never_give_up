class Activity {
  const Activity({
    required this.id,
    required this.name,
    required this.emoji,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String emoji;
  final bool active;
  final DateTime createdAt;

  Activity copyWith({
    String? name,
    String? emoji,
    bool? active,
  }) {
    return Activity(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      active: active ?? this.active,
      createdAt: createdAt,
    );
  }
}
