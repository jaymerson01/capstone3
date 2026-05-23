class IncidentCategory {
  final String id;
  final String name;
  final String description;

  IncidentCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  IncidentCategory copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return IncidentCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
