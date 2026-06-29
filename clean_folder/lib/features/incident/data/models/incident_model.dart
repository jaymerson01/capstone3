import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/incident_entity.dart';

part 'incident_model.g.dart';

enum IncidentStatus {
  pending,
  inProgress,
  resolved,
}

extension IncidentStatusExtension on IncidentStatus {
  static IncidentStatus fromString(String status) {
    switch (status) {
      case 'inProgress':
        return IncidentStatus.inProgress;
      case 'resolved':
        return IncidentStatus.resolved;
      case 'pending':
      default:
        return IncidentStatus.pending;
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

  const IncidentModel({
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
  }) : super(
          id: id,
          reporterId: reporterId,
          description: description,
          category: category,
          photoUrl: photoUrl,
          status: status,
          timestamp: timestamp,
          latitude: latitude,
          longitude: longitude,
          resolvedAddress: resolvedAddress,
          upvoteCount: upvoteCount,
          validatedUserIds: validatedUserIds,
        );

  factory IncidentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    final rawStatus = data['status'] as String? ?? 'pending';
    final mappedStatus = IncidentStatusExtension.fromString(rawStatus).name;

    DateTime parsedTimestamp;
    final dynamic rawTimestamp = data['timestamp'];
    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.parse(rawTimestamp);
    } else {
      parsedTimestamp = DateTime.now();
    }

    return IncidentModel(
      id: doc.id,
      reporterId: data['reporterId'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      status: mappedStatus,
      timestamp: parsedTimestamp,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      resolvedAddress: data['resolvedAddress'] as String?,
      upvoteCount: data['upvoteCount'] as int? ?? 0,
      validatedUserIds: List<String>.from(data['validatedUserIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    final mappedStatus = IncidentStatusExtension.fromString(status).name;
    return {
      'reporterId': reporterId,
      'description': description,
      'category': category,
      'photoUrl': photoUrl,
      'status': mappedStatus,
      'timestamp': Timestamp.fromDate(timestamp),
      'latitude': latitude,
      'longitude': longitude,
      'resolvedAddress': resolvedAddress,
      'upvoteCount': upvoteCount,
      'validatedUserIds': validatedUserIds,
    };
  }
}
