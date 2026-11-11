import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/utils/departments.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/helpers/area_analytics.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

final _filed = DateTime(2026, 11, 11, 8);

IncidentEntity report(
  String area,
  String category, {
  String status = 'pending',
  int? respondMin,
  int? resolveMin,
  int? rating,
  String? urgency,
  String? responder,
}) =>
    IncidentEntity(
      id: '$area$category$status$respondMin',
      reporterId: 'r',
      description: '',
      category: category,
      status: status,
      urgencyStatus: urgency,
      timestamp: _filed,
      inProgressAt: respondMin == null ? null : _filed.add(Duration(minutes: respondMin)),
      resolvedAt: resolveMin == null ? null : _filed.add(Duration(minutes: resolveMin)),
      latitude: 14.4851,
      longitude: 121.0116,
      areaSector: area,
      rating: rating,
      assignedResponderId: responder,
    );

void main() {
  final reports = [
    report('Area 1 - San Jose', 'Theft / Robbery', status: 'resolved', respondMin: 10, resolveMin: 60, rating: 4),
    report('Area 1 - San Jose', 'Theft / Robbery', status: 'resolved', respondMin: 20, resolveMin: 120, rating: 5),
    report('Area 1 - San Jose', 'Fire Incident', urgency: 'CRITICAL'),
    report('Area 2 - Airborne', 'Medical Emergency', status: 'in_progress', respondMin: 5, responder: 'h1'),
  ];

  test('areas are listed busiest first with their averages', () {
    final rows = AreaAnalytics.byArea(reports);
    expect(rows.map((r) => r.area), ['Area 1 - San Jose', 'Area 2 - Airborne']);

    final sanJose = rows.first;
    expect(sanJose.total, 3);
    expect(sanJose.open, 1);
    expect(sanJose.critical, 1);
    expect(sanJose.topCategory, 'Theft / Robbery');
    expect(sanJose.resolvedShare, closeTo(2 / 3, 0.001));
    expect(sanJose.avgTimeToRespond, const Duration(minutes: 15));
    expect(sanJose.avgTimeToResolve, const Duration(minutes: 90));
    expect(sanJose.avgRating, 4.5);
    expect(rows.last.avgRating, isNull);
  });

  test("departments count every report routed to them", () {
    final rows = {for (final r in AreaAnalytics.byDepartment(reports)) r.department: r};
    expect(rows[Department.pnp]!.total, 2); // the two thefts
    expect(rows[Department.bfp]!.total, 1);
    expect(rows[Department.bfp]!.unassigned, 1);
    expect(rows[Department.tanod]!.total, 3); // thefts and the fire
    expect(rows[Department.health]!.open, 1);
    expect(rows[Department.health]!.unassigned, 0);
    expect(rows[Department.health]!.avgTimeToRespond, const Duration(minutes: 5));
  });
}
