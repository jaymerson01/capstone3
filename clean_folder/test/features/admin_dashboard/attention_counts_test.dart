import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/attention_row.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

IncidentEntity report(String id, String category, {String status = 'pending', String? responder, String? progress}) =>
    IncidentEntity(
      id: id,
      reporterId: 'r',
      description: '',
      category: category,
      status: status,
      timestamp: DateTime(2026, 11, 11, 9),
      latitude: 14.4851,
      longitude: 121.0116,
      assignedResponderId: responder,
      responderStatus: progress,
    );

void main() {
  test('counts what the desk should act on now', () {
    final counts = AttentionCounts.from([
      report('fire', 'Fire Incident'), // critical, unassigned
      report('medical', 'Medical Emergency', status: 'in_progress', responder: 'h1', progress: 'on_the_way'),
      report('noise', 'Noise Complaint'), // unassigned, not critical
      report('old_fire', 'Fire Incident', status: 'resolved'),
    ], idChecks: 2);

    expect(counts.criticalOpen, 2);
    expect(counts.waitingForResponder, 2);
    expect(counts.respondersOnTheWay, 1);
    expect(counts.idChecks, 2);
  });
}
