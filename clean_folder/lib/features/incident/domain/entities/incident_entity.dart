class IncidentEntity {
  final String id;
  final String reporterId;
  final String description;
  final String category;
  final String? photoUrl;
  final String status;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String? resolvedAddress;
  final int upvoteCount;
  final List<String> validatedUserIds;

  const IncidentEntity({
    required this.id,
    required this.reporterId,
    required this.description,
    required this.category,
    this.photoUrl,
    required this.status,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.resolvedAddress,
    this.upvoteCount = 0,
    this.validatedUserIds = const [],
  });
}
