import 'dart:math';

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
  final bool isBlotter;

  /// When an admin last wrote [dispatcherNotes], the comment residents see.
  final DateTime? dispatcherNotesAt;

  /// When the report was marked resolved.
  final DateTime? resolvedAt;

  /// When an admin last moved the report to In progress.
  final DateTime? inProgressAt;

  /// When the barangay closed the report without resolving it (spam or
  /// archived).
  final DateTime? closedAt;

  /// Whether an admin has verified the reporter's residency (admin desk only;
  /// null when the reporter's profile isn't loaded).
  final bool? reporterVerified;

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
    this.isBlotter = false,
    this.dispatcherNotesAt,
    this.resolvedAt,
    this.reporterVerified,
    this.inProgressAt,
    this.closedAt,
  });

  /// The reference residents and the desk quote for this report, e.g.
  /// RQ-261104-AB3XK: the filing date (Philippine time) and the start of the
  /// report's ID, so every app shows the same number without storing one.
  String get ticketNumber {
    if (id.isEmpty) return '';
    final ph = timestamp.toUtc().add(const Duration(hours: 8));
    String two(int n) => n.toString().padLeft(2, '0');
    final code = id.substring(0, id.length < 5 ? id.length : 5).toUpperCase();
    return 'RQ-${two(ph.year % 100)}${two(ph.month)}${two(ph.day)}-$code';
  }

  /// A new report ID, made on the phone so the ticket number is known before
  /// the report reaches the server (or while it waits offline). Same shape as
  /// Firestore's own IDs.
  static String newId([Random? random]) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rng = random ?? Random.secure();
    return List.generate(20, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  /// Physical incidents, which must come with a photo or video.
  static const List<String> evidenceRequiredCategories = [
    'Theft / Robbery',
    'Violence / Physical Fight',
    'Road Accident',
    'Fire Incident',
  ];

  static bool requiresEvidence(String? category) =>
      category != null && evidenceRequiredCategories.contains(category);

  /// Categories a resident may record as a barangay blotter entry.
  static const List<String> blotterCategories = [
    'Violence / Physical Fight',
    'Theft / Robbery',
    'Noise Complaint',
    'Suspicious Activity',
    'Lost Item / Missing Person',
  ];

  static bool isBlotterCategory(String? category) =>
      category != null && blotterCategories.contains(category);

  bool get isSolved {
    final s = status.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim();
    return s == 'solved' || s == 'resolved';
  }

  bool get isInProgress {
    final s = status.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim();
    return s == 'inprogress';
  }

  /// Spam or archived: closed by the barangay without a resolution.
  bool get isClosed {
    final s = status.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim();
    return s == 'spam' || s == 'archived';
  }

  bool get isPending {
    final s = status.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim();
    return s == 'pending';
  }
}
