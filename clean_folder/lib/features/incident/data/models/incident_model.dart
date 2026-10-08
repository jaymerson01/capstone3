import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/incident_entity.dart';
import '../../../../core/utils/incident_triage_helper.dart';

part 'incident_model.g.dart';

enum IncidentStatus {
  pending,
  inProgress,
  resolved,
  spam,
  archived,
}

extension IncidentStatusExtension on IncidentStatus {
  static IncidentStatus fromString(String status) {
    switch (status.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim()) {
      case 'inprogress':
        return IncidentStatus.inProgress;
      case 'resolved':
      case 'solved':
        return IncidentStatus.resolved;
      case 'spam':
        return IncidentStatus.spam;
      case 'archived':
        return IncidentStatus.archived;
      case 'pending':
      default:
        return IncidentStatus.pending;
    }
  }

  static String normalize(String status) {
    switch (status.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim()) {
      case 'inprogress':
        return 'in_progress';
      case 'resolved':
      case 'solved':
        return 'resolved';
      case 'spam':
        return 'spam';
      case 'archived':
        return 'archived';
      case 'pending':
      default:
        return 'pending';
    }
  }
}

@HiveType(typeId: 1)
class IncidentModel extends IncidentEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String reporterId;

  @HiveField(2)
  @override
  final String description;

  @HiveField(3)
  @override
  final String category;

  @HiveField(4)
  @override
  final String? photoUrl;

  @HiveField(5)
  @override
  final String status;

  @HiveField(12)
  @override
  final String? urgencyStatus;

  @HiveField(6)
  @override
  final DateTime timestamp;

  @HiveField(7)
  @override
  final double latitude;

  @HiveField(8)
  @override
  final double longitude;

  @HiveField(9)
  @override
  final String? resolvedAddress;

  @HiveField(10)
  @override
  final int upvoteCount;

  @HiveField(11)
  @override
  final List<String> validatedUserIds;

  @HiveField(13)
  @override
  final String? areaSector;

  @HiveField(14)
  @override
  final bool isAnonymous;

  @HiveField(15)
  @override
  final String? dispatcherNotes;

  @HiveField(16)
  @override
  final String? reporterName;

  @HiveField(17)
  @override
  final String? reporterEmail;

  @HiveField(18)
  @override
  final String? videoUrl;

  @HiveField(19)
  @override
  final bool isReportingOnBehalf;

  @HiveField(20)
  @override
  final String? victimName;

  @HiveField(21)
  @override
  final String? victimPhone;

  @HiveField(22)
  @override
  final String? estimatedResponseTime;

  @override
  final bool isSynced;

  IncidentModel copyWith({
    String? id,
    String? reporterId,
    String? description,
    String? category,
    String? photoUrl,
    String? videoUrl,
    String? status,
    String? urgencyStatus,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? resolvedAddress,
    int? upvoteCount,
    List<String>? validatedUserIds,
    String? areaSector,
    bool? isAnonymous,
    String? dispatcherNotes,
    String? reporterName,
    String? reporterEmail,
    bool? isSynced,
    DateTime? respondedAt,
    bool? isReportingOnBehalf,
    String? victimName,
    String? victimPhone,
    String? estimatedResponseTime,
  }) {
    return IncidentModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      description: description ?? this.description,
      category: category ?? this.category,
      photoUrl: photoUrl ?? this.photoUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      status: status ?? this.status,
      urgencyStatus: urgencyStatus ?? this.urgencyStatus,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      resolvedAddress: resolvedAddress ?? this.resolvedAddress,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      validatedUserIds: validatedUserIds ?? this.validatedUserIds,
      areaSector: areaSector ?? this.areaSector,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      dispatcherNotes: dispatcherNotes ?? this.dispatcherNotes,
      reporterName: reporterName ?? this.reporterName,
      reporterEmail: reporterEmail ?? this.reporterEmail,
      isSynced: isSynced ?? this.isSynced,
      respondedAt: respondedAt ?? this.respondedAt,
      isReportingOnBehalf: isReportingOnBehalf ?? this.isReportingOnBehalf,
      victimName: victimName ?? this.victimName,
      victimPhone: victimPhone ?? this.victimPhone,
      estimatedResponseTime: estimatedResponseTime ?? this.estimatedResponseTime,
    );
  }

  const IncidentModel({
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
    super.respondedAt,
    this.isReportingOnBehalf = false,
    this.victimName,
    this.victimPhone,
    this.estimatedResponseTime,
  }) : super(
          id: id,
          reporterId: reporterId,
          description: description,
          category: category,
          photoUrl: photoUrl,
          videoUrl: videoUrl,
          status: status,
          urgencyStatus: urgencyStatus,
          timestamp: timestamp,
          latitude: latitude,
          longitude: longitude,
          resolvedAddress: resolvedAddress,
          upvoteCount: upvoteCount,
          validatedUserIds: validatedUserIds,
          areaSector: areaSector,
          isAnonymous: isAnonymous,
          dispatcherNotes: dispatcherNotes,
          reporterName: reporterName,
          reporterEmail: reporterEmail,
          isSynced: isSynced,
          isReportingOnBehalf: isReportingOnBehalf,
          victimName: victimName,
          victimPhone: victimPhone,
          estimatedResponseTime: estimatedResponseTime,
        );

  factory IncidentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    final rawStatus = data['status'] as String? ?? 'pending';
    final mappedStatus = IncidentStatusExtension.normalize(rawStatus);

    DateTime parsedTimestamp;
    final dynamic rawTimestamp = data['timestamp'];
    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.parse(rawTimestamp);
    } else {
      parsedTimestamp = DateTime.now();
    }

    DateTime? parsedRespondedAt;
    final dynamic rawRespondedAt = data['respondedAt'] ?? data['updatedAt'];
    if (rawRespondedAt is Timestamp) {
      parsedRespondedAt = rawRespondedAt.toDate();
    } else if (rawRespondedAt is String) {
      parsedRespondedAt = DateTime.tryParse(rawRespondedAt);
    }

    final rawUrgency = data['urgencyStatus'] as String?;
    final String resolvedUrgency = (rawUrgency != null &&
            rawUrgency.isNotEmpty &&
            rawUrgency.toLowerCase() != 'pending')
        ? rawUrgency
        : IncidentTriageHelper.calculateEffectiveUrgency(
            category: data['category'] as String? ?? '',
            upvoteCount: (data['upvoteCount'] as num?)?.toInt() ?? 0,
          );

    return IncidentModel(
      id: doc.id,
      reporterId: data['reporterId'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      videoUrl: data['videoUrl'] as String?,
      status: mappedStatus,
      urgencyStatus: resolvedUrgency,
      timestamp: parsedTimestamp,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      resolvedAddress: (data['resolvedAddress'] as String?)?.isNotEmpty == true
          ? data['resolvedAddress'] as String
          : data['areaSector'] as String?,
      upvoteCount: data['upvoteCount'] as int? ?? 0,
      validatedUserIds: List<String>.from(data['validatedUserIds'] ?? []),
      areaSector: (data['areaSector'] as String?)?.isNotEmpty == true
          ? data['areaSector'] as String
          : data['resolvedAddress'] as String?,
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      dispatcherNotes: data['dispatcherNotes'] as String?,
      reporterName: data['reporterName'] as String?,
      reporterEmail: data['reporterEmail'] as String?,
      isSynced: !doc.metadata.hasPendingWrites,
      respondedAt: parsedRespondedAt,
      isReportingOnBehalf: data['isReportingOnBehalf'] as bool? ?? false,
      victimName: data['victimName'] as String?,
      victimPhone: data['victimPhone'] as String?,
      estimatedResponseTime: data['estimatedResponseTime'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    final mappedStatus = IncidentStatusExtension.normalize(status);
    final effectiveAddress = (resolvedAddress != null && resolvedAddress!.isNotEmpty)
        ? resolvedAddress
        : areaSector;
    final effectiveSector = (areaSector != null && areaSector!.isNotEmpty)
        ? areaSector
        : effectiveAddress;
    final map = <String, dynamic>{
      'reporterId': reporterId,
      'description': description,
      'category': category,
      'photoUrl': photoUrl,
      'videoUrl': videoUrl,
      'status': mappedStatus,
      'urgencyStatus': urgencyStatus,
      'timestamp': Timestamp.fromDate(timestamp),
      'latitude': latitude,
      'longitude': longitude,
      'resolvedAddress': effectiveAddress,
      'upvoteCount': upvoteCount,
      'validatedUserIds': validatedUserIds,
      'areaSector': effectiveSector,
      'isAnonymous': isAnonymous,
      'dispatcherNotes': dispatcherNotes,
      'reporterName': reporterName,
      'reporterEmail': reporterEmail,
      'isReportingOnBehalf': isReportingOnBehalf,
      'victimName': victimName,
      'victimPhone': victimPhone,
      'estimatedResponseTime': estimatedResponseTime,
    };
    if (respondedAt != null) {
      map['respondedAt'] = Timestamp.fromDate(respondedAt!);
    }
    return map;
  }
}
