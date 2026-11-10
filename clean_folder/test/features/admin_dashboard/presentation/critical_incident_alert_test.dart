import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/critical_incident_alert.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

final _opened = DateTime(2026, 11, 4, 9);

IncidentEntity report(
  String id, {
  String category = 'Fire Incident',
  String status = 'pending',
  int upvotes = 0,
  Duration filedBeforeOpening = Duration.zero,
}) =>
    IncidentEntity(
      id: id,
      reporterId: 'resident_1',
      description: 'Usok sa kusina',
      category: category,
      status: status,
      timestamp: _opened.subtract(filedBeforeOpening),
      latitude: 14.48,
      longitude: 121.01,
      upvoteCount: upvotes,
    );

void main() {
  test('pops up a new critical report once', () {
    final tracker = CriticalAlertTracker(openedAt: _opened);
    final fire = report('fire1');
    expect(tracker.take([fire]).map((i) => i.id), ['fire1']);
    expect(tracker.take([fire]), isEmpty, reason: 'already shown');
  });

  test('ignores reports that are not critical or already closed', () {
    final tracker = CriticalAlertTracker(openedAt: _opened);
    expect(
      tracker.take([
        report('noise', category: 'Noise Complaint'),
        report('done', status: 'resolved'),
        report('spam', status: 'spam'),
      ]),
      isEmpty,
    );
  });

  test('skips old critical reports already on the desk at sign-in', () {
    final tracker = CriticalAlertTracker(openedAt: _opened);
    expect(tracker.take([report('old', filedBeforeOpening: const Duration(hours: 3))]), isEmpty);
    expect(
      tracker.take([report('recent', filedBeforeOpening: const Duration(minutes: 5))]).map((i) => i.id),
      ['recent'],
    );
  });

  test('pops up an older report when neighbours escalate it to critical', () {
    final tracker = CriticalAlertTracker(openedAt: _opened);
    final theft = report('theft', category: 'Theft / Robbery', filedBeforeOpening: const Duration(hours: 2));
    expect(tracker.take([theft]), isEmpty, reason: 'HIGH, not critical yet');
    final escalated = report('theft',
        category: 'Theft / Robbery', upvotes: 2, filedBeforeOpening: const Duration(hours: 2));
    expect(tracker.take([escalated]).map((i) => i.id), ['theft']);
  });

  test('ticket numbers use the Philippine date and the start of the ID', () {
    final filed = IncidentEntity(
      id: 'ab3xk9ZqP0',
      reporterId: 'r',
      description: '',
      category: 'Fire Incident',
      status: 'pending',
      // 20:30 UTC on Nov 3 is already Nov 4 in Manila.
      timestamp: DateTime.utc(2026, 11, 3, 20, 30),
      latitude: 0,
      longitude: 0,
    );
    expect(filed.ticketNumber, 'RQ-261104-AB3XK');
    expect(IncidentEntity.requiresEvidence('Road Accident'), isTrue);
    expect(IncidentEntity.requiresEvidence('Medical Emergency'), isFalse);
  });
}
