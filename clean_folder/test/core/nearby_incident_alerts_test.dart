import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/widgets/nearby_incident_alerts.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

IncidentEntity fire(String id, double lat, double lng, {String reporter = 'neighbour'}) => IncidentEntity(
      id: id,
      reporterId: reporter,
      description: 'Sunog',
      category: 'Fire Incident',
      status: 'pending',
      timestamp: DateTime(2026, 11, 11, 9),
      latitude: lat,
      longitude: lng,
    );

void main() {
  // Moonwalk Proper's centre.
  const lat = 14.4851, lng = 121.0116;

  test('only reports within 500 m filed by someone else', () {
    final matches = NearbyIncidentAlerts.near(
      [
        fire('close', 14.4869, 121.0116), // ~200 m north
        fire('far', 14.4941, 121.0116), // ~1 km north
        fire('mine', 14.4852, 121.0116, reporter: 'me'),
        fire('no_location', 0, 0),
      ],
      userId: 'me',
      latitude: lat,
      longitude: lng,
    );
    expect(matches.map((m) => m.$1.id), ['close']);
    expect(matches.single.$2, closeTo(200, 10));
  });
}
