class AreaInfo {
  final String id;
  final String name;
  int incidentsCount;

  AreaInfo({
    required this.id,
    required this.name,
    required this.incidentsCount,
  });

  AreaInfo copyWith({
    String? id,
    String? name,
    int? incidentsCount,
  }) {
    return AreaInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      incidentsCount: incidentsCount ?? this.incidentsCount,
    );
  }
}
