class AreaInfo {
  final String id;
  final String name;
  int incidentsCount;
  bool isArchived;

  AreaInfo({
    required this.id,
    required this.name,
    required this.incidentsCount,
    this.isArchived = false,
  });

  AreaInfo copyWith({
    String? id,
    String? name,
    int? incidentsCount,
    bool? isArchived,
  }) {
    return AreaInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      incidentsCount: incidentsCount ?? this.incidentsCount,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'incidentsCount': incidentsCount,
      'isArchived': isArchived,
    };
  }

  factory AreaInfo.fromJson(Map<String, dynamic> json) {
    return AreaInfo(
      id: json['id'],
      name: json['name'],
      incidentsCount: json['incidentsCount'],
      isArchived: json['isArchived'] ?? false,
    );
  }
}
