import 'package:flutter_test/flutter_test.dart';
import 'package:main_folder/admin/models/incident_report.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Incident Report Model & Serialization Tests', () {
    test('IncidentReport serializes to and from JSON cleanly with coordinates', () {
      final now = DateTime.now();
      final report = IncidentReport(
        id: "INC-TEST-001",
        incidentType: "Fire Incident",
        reporterName: "John Resident",
        location: "Barangay Moonwalk Phase 1",
        description: "Kitchen fire reported",
        urgencyLevel: "High",
        status: IncidentStatus.pending,
        latitude: 14.4793,
        longitude: 121.0198,
        date: now,
        isArchived: false,
      );

      final json = report.toJson();
      expect(json['id'], "INC-TEST-001");
      expect(json['latitude'], 14.4793);
      expect(json['longitude'], 121.0198);
      expect(json['isArchived'], false);

      final deserialized = IncidentReport.fromJson(json);
      expect(deserialized.id, report.id);
      expect(deserialized.incidentType, report.incidentType);
      expect(deserialized.latitude, 14.4793);
      expect(deserialized.longitude, 121.0198);
      expect(deserialized.status, IncidentStatus.pending);
    });

    test('IncidentStatus labels match design specs', () {
      expect(IncidentStatus.pending.name, "pending");
      expect(IncidentStatus.inProgress.name, "inProgress");
      expect(IncidentStatus.solved.name, "solved");
      expect(IncidentStatus.spam.name, "spam");
    });
  });
}
