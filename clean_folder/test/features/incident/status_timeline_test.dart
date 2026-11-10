import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/features/incident/data/repositories/incident_repository_impl.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/widgets/incident_status_timeline.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

final en = lookupAppLocalizations(const Locale('en'));
final fil = lookupAppLocalizations(const Locale('fil'));
final filed = DateTime(2026, 11, 5, 8, 30);

IncidentEntity report({
  String status = 'pending',
  bool synced = true,
  DateTime? inProgressAt,
  DateTime? resolvedAt,
  DateTime? closedAt,
  String? eta,
}) =>
    IncidentEntity(
      id: 'ab3xk9ZqP0',
      reporterId: 'r1',
      description: 'Sunog',
      category: 'Fire Incident',
      status: status,
      timestamp: filed,
      latitude: 14.48,
      longitude: 121.01,
      isSynced: synced,
      inProgressAt: inProgressAt,
      resolvedAt: resolvedAt,
      closedAt: closedAt,
      estimatedResponseTime: eta,
    );

List<String> describe(IncidentEntity incident, AppLocalizations l10n) => [
      for (final s in IncidentStatusTimeline.stagesFor(incident, l10n))
        '${s.state.name}: ${s.label}${s.detail == null ? '' : ' (${s.detail})'}',
    ];

void main() {
  test('pending: received, waiting for the barangay', () {
    expect(describe(report(), fil), [
      'done: Natanggap ang ulat (05/11/2026 08:30)',
      'current: Hinihintay ang barangay',
      'upcoming: Nalutas',
    ]);
  });

  test('in progress: when it started and the ETA', () {
    final incident = report(status: 'in_progress', inProgressAt: DateTime(2026, 11, 5, 8, 42), eta: '10 mins');
    expect(describe(incident, en)[1], startsWith('current: Barangay is responding (Since 05/11/2026 08:42 · '));
    expect(describe(incident, en)[1], contains('10 mins'));
  });

  test('resolved: every stage done with its time', () {
    final incident = report(
      status: 'resolved',
      inProgressAt: DateTime(2026, 11, 5, 8, 42),
      resolvedAt: DateTime(2026, 11, 5, 9, 15),
    );
    expect(describe(incident, fil), [
      'done: Natanggap ang ulat (05/11/2026 08:30)',
      'done: Inaaksyunan ng barangay (05/11/2026 08:42)',
      'done: Nalutas (05/11/2026 09:15)',
    ]);
  });

  test('spam or archived: closed by the barangay', () {
    expect(describe(report(status: 'spam', closedAt: DateTime(2026, 11, 5, 9)), en), [
      'done: Report received (05/11/2026 08:30)',
      'done: Closed by the barangay (05/11/2026 09:00)',
    ]);
  });

  test('saved offline: waiting for internet', () {
    expect(describe(report(synced: false), en).first, 'current: Waiting for internet to send (05/11/2026 08:30)');
  });

  test('status notices are bilingual and carry the ticket number', () {
    final notice = IncidentRepositoryImpl.statusNotice(
      status: 'in_progress',
      ticket: 'RQ-261105-AB3XK',
      category: 'Fire Incident',
      eta: '10 mins',
      notes: 'Papunta na ang tanod',
    );
    expect(notice.title, 'Inaaksyunan na ang ulat mo · Your report is being handled');
    expect(notice.message,
        'Ticket RQ-261105-AB3XK · Fire Incident · ETA: 10 mins · Komento / Comment: Papunta na ang tanod');
    expect(
      IncidentRepositoryImpl.statusNotice(status: 'resolved', ticket: '', category: 'Theft / Robbery').message,
      'Theft / Robbery',
    );
  });
}
