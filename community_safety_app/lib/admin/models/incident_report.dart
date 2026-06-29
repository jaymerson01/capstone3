import 'package:flutter/material.dart';

enum IncidentStatus {
  pending,
  inProgress,
  solved,
  spam,
}

class IncidentReport {
  final String id;
  final String incidentType;
  final String reporterName;
  final String location;
  final DateTime date;
  IncidentStatus status;
  String description;
  final String urgencyLevel;
  bool isArchived;

  IncidentReport({
    required this.id,
    required this.incidentType,
    required this.reporterName,
    required this.location,
    required this.date,
    required this.status,
    required this.description,
    required this.urgencyLevel,
    this.isArchived = false,
  });

  String get statusLabel {
    switch (status) {
      case IncidentStatus.pending:
        return 'Pending';
      case IncidentStatus.inProgress:
        return 'In Progress';
      case IncidentStatus.solved:
        return 'Solved';
      case IncidentStatus.spam:
        return 'Spam';
    }
  }

  Color get statusColor {
    switch (status) {
      case IncidentStatus.pending:
        return Colors.orange;
      case IncidentStatus.inProgress:
        return Colors.blue;
      case IncidentStatus.solved:
        return Colors.green;
      case IncidentStatus.spam:
        return Colors.red;
    }
  }

  IncidentReport copyWith({
    String? id,
    String? incidentType,
    String? reporterName,
    String? location,
    DateTime? date,
    IncidentStatus? status,
    String? description,
    String? urgencyLevel,
    bool? isArchived,
  }) {
    return IncidentReport(
      id: id ?? this.id,
      incidentType: incidentType ?? this.incidentType,
      reporterName: reporterName ?? this.reporterName,
      location: location ?? this.location,
      date: date ?? this.date,
      status: status ?? this.status,
      description: description ?? this.description,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incidentType': incidentType,
      'reporterName': reporterName,
      'location': location,
      'date': date.toIso8601String(),
      'status': status.name,
      'description': description,
      'urgencyLevel': urgencyLevel,
      'isArchived': isArchived,
    };
  }

  factory IncidentReport.fromJson(Map<String, dynamic> json) {
    return IncidentReport(
      id: json['id'],
      incidentType: json['incidentType'],
      reporterName: json['reporterName'],
      location: json['location'],
      date: DateTime.parse(json['date']),
      status: IncidentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IncidentStatus.pending,
      ),
      description: json['description'],
      urgencyLevel: json['urgencyLevel'],
      isArchived: json['isArchived'] ?? false,
    );
  }
}