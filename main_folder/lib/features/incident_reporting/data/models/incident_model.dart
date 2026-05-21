enum IncidentStatus {
  pending,
  verified,
  rejected,
  resolved,
}

// Serialization helpers for IncidentStatus lifecycle
extension IncidentStatusExtension on IncidentStatus {
  String get name {
    switch (this) {
      case IncidentStatus.pending:
        return 'pending';
      case IncidentStatus.verified:
        return 'verified';
      case IncidentStatus.rejected:
        return 'rejected';
      case IncidentStatus.resolved:
        return 'resolved';
    }
  }

  static IncidentStatus fromString(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'verified':
        return IncidentStatus.verified;
      case 'rejected':
        return IncidentStatus.rejected;
      case 'resolved':
        return IncidentStatus.resolved;
      case 'pending':
      default:
        return IncidentStatus.pending;
    }
  }
}

class IncidentModel {
  final String id;
  final String residentId;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String humanReadableAddress;
  final DateTime timestamp;
  final String imagePath;
  final IncidentStatus status;

  const IncidentModel({
    required this.id,
    required this.residentId,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.humanReadableAddress,
    required this.timestamp,
    required this.imagePath,
    this.status = IncidentStatus.pending,
  });

  // Factory constructor for converting from Firestore JSON
  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'] as String? ?? '',
      residentId: json['residentId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      humanReadableAddress: json['humanReadableAddress'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      imagePath: json['imagePath'] as String? ?? '',
      status: IncidentStatusExtension.fromString(json['status'] as String? ?? 'pending'),
    );
  }

  // Convert to Firestore JSON structure
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'residentId': residentId,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'humanReadableAddress': humanReadableAddress,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
      'status': status.name,
    };
  }

  // Support for state transitions/modifications
  IncidentModel copyWith({
    String? id,
    String? residentId,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? humanReadableAddress,
    DateTime? timestamp,
    String? imagePath,
    IncidentStatus? status,
  }) {
    return IncidentModel(
      id: id ?? this.id,
      residentId: residentId ?? this.residentId,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      humanReadableAddress: humanReadableAddress ?? this.humanReadableAddress,
      timestamp: timestamp ?? this.timestamp,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
    );
  }
}
