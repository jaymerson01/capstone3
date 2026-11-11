import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/utils/resident_access.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';

const _unverified = UserEntity(id: 'r1', email: 'ana@gmail.com');
const _verified = UserEntity(id: 'r1', email: 'ana@gmail.com', isVerified: true);

IncidentEntity _report(DateTime at, {String reporter = 'r1'}) => IncidentEntity(
      id: '${at.millisecondsSinceEpoch}$reporter',
      reporterId: reporter,
      description: '',
      category: 'Noise Complaint',
      status: 'pending',
      timestamp: at,
      latitude: 14.4851,
      longitude: 121.0116,
    );

void main() {
  // 10:00 in Manila (UTC+8).
  final now = DateTime.utc(2026, 11, 11, 2);

  test('reports count per Philippine day, only the resident\'s own', () {
    final reports = [
      _report(DateTime.utc(2026, 11, 10, 16, 30)), // 00:30 today in Manila
      _report(DateTime.utc(2026, 11, 10, 15, 30)), // 23:30 yesterday in Manila
      _report(DateTime.utc(2026, 11, 11, 1)),
      _report(DateTime.utc(2026, 11, 11, 1), reporter: 'someone-else'),
    ];
    expect(ResidentAccess.reportsToday(reports, 'r1', now: now), 2);
    expect(ResidentAccess.reportsLeftToday(_unverified, reports, now: now), 1);
    expect(ResidentAccess.reportsLeftToday(_verified, reports, now: now), isNull);
  });

  test('after the daily limit only emergencies go through, unless verified', () {
    final three = [for (var h = 0; h < 3; h++) _report(DateTime.utc(2026, 11, 11, h))];
    expect(ResidentAccess.canFile(_unverified, 'Noise Complaint', three, now: now), isFalse);
    expect(ResidentAccess.canFile(_unverified, 'Suspicious Activity', three, now: now), isFalse);
    for (final emergency in ResidentAccess.emergencyCategories) {
      expect(ResidentAccess.canFile(_unverified, emergency, three, now: now), isTrue, reason: emergency);
    }
    expect(ResidentAccess.canFile(_verified, 'Noise Complaint', three, now: now), isTrue);
    expect(ResidentAccess.canFile(_unverified, 'Noise Complaint', three.take(2), now: now), isTrue);
  });

  test('only verified residents see the community or report anonymously', () {
    expect(ResidentAccess.canSeeCommunity(_unverified), isFalse);
    expect(ResidentAccess.canReportAnonymouslyOrForOthers(_unverified), isFalse);
    expect(ResidentAccess.canSeeCommunity(_verified), isTrue);
    expect(ResidentAccess.canReportAnonymouslyOrForOthers(_verified), isTrue);
  });

  test('unverified residents stream only their own reports', () {
    final own = ResidentAccess.streamFor(_unverified);
    expect(own, isA<StreamUserIncidentsRequested>());
    expect((own as StreamUserIncidentsRequested).userId, 'r1');
    expect(ResidentAccess.streamFor(_verified), isA<StreamActiveIncidentsRequested>());
  });
}
