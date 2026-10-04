class IncidentEntity {
  final String id;
  final String reporterId;
  final String description;
  final String category;
  final String? photoUrl;
  final String? videoUrl;
  final String status;
  final String? urgencyStatus;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String? resolvedAddress;
  final int upvoteCount;
  final List<String> validatedUserIds;
  final String? areaSector;
  final bool isAnonymous;
  final String? dispatcherNotes;
  final String? reporterName;
  final String? reporterEmail;
  final bool isSynced;
  final DateTime? respondedAt;
  final bool isReportingOnBehalf;
  final String? victimName;
  final String? victimPhone;
  final String? estimatedResponseTime;

  const IncidentEntity({
    required this.id,
    required this.reporterId,
    required this.description,
    required this.category,
    this.photoUrl,
    this.videoUrl,
    required this.status,
    this.urgencyStatus,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.resolvedAddress,
    this.upvoteCount = 0,
    this.validatedUserIds = const [],
    this.areaSector,
    this.isAnonymous = false,
    this.dispatcherNotes,
    this.reporterName,
    this.reporterEmail,
    this.isSynced = true,
    this.respondedAt,
    this.isReportingOnBehalf = false,
    this.victimName,
    this.victimPhone,
    this.estimatedResponseTime,
  });

  bool get isSolved {
    final s = status.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim();
    return s == 'solved' || s == 'resolved';
  }

  bool get isInProgress {
    final s = status.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim();
    return s == 'inprogress';
  }

  bool get isPending {
    final s = status.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim();
    return s == 'pending';
  }
}
