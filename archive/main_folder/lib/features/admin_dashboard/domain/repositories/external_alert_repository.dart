import '../../../incident_reporting/data/models/incident_model.dart';

abstract class ExternalAlertRepository {
  /// Triggers a native dispatch action to external disaster and emergency teams
  /// (e.g., PNP for crime control, BFP for fire breakouts, or barangay responders).
  /// 
  /// Utilizes the [incident] model for data contexts like location, description, and attachments.
  Future<bool> dispatchExternalEmergency({
    required IncidentModel incident,
    required String targetAgency, // e.g., 'PNP', 'BFP', 'Red Cross', 'Barangay Rescue'
    String? priorityNotes,
  });

  /// Queries the live dispatch response timeline and return status from
  /// the integrated government portal.
  Future<Map<String, dynamic>> checkDispatchStatus({
    required String alertId,
  });
}
