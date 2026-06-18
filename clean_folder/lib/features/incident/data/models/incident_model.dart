import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/incident_entity.dart';

class IncidentModel extends IncidentEntity {
  const IncidentModel({
    required super.id,
    required super.title,
    required super.description,
    required super.latitude,
    required super.longitude,
    super.photoUrl,
    required super.status,
    required super.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrl': photoUrl,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory IncidentModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedTimestamp;
    final dynamic rawTimestamp = map['timestamp'];
    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.parse(rawTimestamp);
    } else {
      parsedTimestamp = DateTime.now();
    }

    return IncidentModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      photoUrl: map['photoUrl'] as String?,
      status: map['status'] as String? ?? 'pending',
      timestamp: parsedTimestamp,
    );
  }
}
