import 'package:flutter/material.dart';
import '../constants/admin_colors.dart';

enum IncidentStatus {
  pending,
  inProgress,
  solved,
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

  // Getter to get human readable status label
  String get statusLabel {
    switch (status) {
      case IncidentStatus.pending:
        return 'Pending';
      case IncidentStatus.inProgress:
        return 'In Progress';
      case IncidentStatus.solved:
        return 'Solved';
    }
  }

  // Getter to match custom status colors
  Color get statusColor {
    switch (status) {
      case IncidentStatus.pending:
        return AdminColors.pendingYellow;
      case IncidentStatus.inProgress:
        return AdminColors.progressBlue;
      case IncidentStatus.solved:
        return AdminColors.solvedGreen;
    }
  }

  // Copy with method to help modify reports in service
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
