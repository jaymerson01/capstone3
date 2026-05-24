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

  IncidentReport({
    required this.id,
    required this.incidentType,
    required this.reporterName,
    required this.location,
    required this.date,
    required this.status,
    required this.description,
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
  }) {
    return IncidentReport(
      id: id ?? this.id,
      incidentType: incidentType ?? this.incidentType,
      reporterName: reporterName ?? this.reporterName,
      location: location ?? this.location,
      date: date ?? this.date,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }
}