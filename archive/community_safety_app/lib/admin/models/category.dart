class IncidentCategory {
  final String id;
  final String name;
  final String description;
  bool isArchived;

  IncidentCategory({
    required this.id,
    required this.name,
    required this.description,
    this.isArchived = false,
  });

  IncidentCategory copyWith({
    String? id,
    String? name,
    String? description,
    bool? isArchived,
  }) {
    return IncidentCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isArchived': isArchived,
    };
  }

  factory IncidentCategory.fromJson(Map<String, dynamic> json) {
    return IncidentCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isArchived: json['isArchived'] ?? false,
    );
  }
}
