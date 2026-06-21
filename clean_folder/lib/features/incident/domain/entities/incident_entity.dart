class IncidentEntity {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final String status;
  final String urgencyStatus;
  final DateTime timestamp;
  final int affectedCount;
  final List<String> affectedUserIds;

  const IncidentEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    required this.status,
    required this.urgencyStatus,
    required this.timestamp,
    this.affectedCount = 1,
    this.affectedUserIds = const [],
  });
}
