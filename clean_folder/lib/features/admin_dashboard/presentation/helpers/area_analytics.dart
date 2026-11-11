import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/core/utils/departments.dart';
import 'package:community_safety_app/core/utils/incident_triage_helper.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

/// One area's numbers for the analytics table.
class AreaStats {
  const AreaStats({
    required this.area,
    required this.total,
    required this.open,
    required this.critical,
    required this.topCategory,
    required this.resolvedShare,
    this.avgTimeToRespond,
    this.avgTimeToResolve,
    this.avgRating,
  });

  final String area;
  final int total;
  final int open;
  final int critical;
  final String topCategory;

  /// Resolved reports out of all of them, 0-1.
  final double resolvedShare;
  final Duration? avgTimeToRespond;
  final Duration? avgTimeToResolve;
  final double? avgRating;
}

/// One department's workload for the analytics table.
class DepartmentStats {
  const DepartmentStats({
    required this.department,
    required this.total,
    required this.open,
    required this.unassigned,
    this.avgTimeToRespond,
  });

  final Department department;
  final int total;
  final int open;

  /// Open reports no responder has taken yet.
  final int unassigned;
  final Duration? avgTimeToRespond;
}

/// The analytics page's per-area and per-department tables.
class AreaAnalytics {
  const AreaAnalytics._();

  static String areaOf(IncidentEntity i) => BarangaySectorHelper.normalizeSector(i.areaSector, i.resolvedAddress);

  static bool _open(IncidentEntity i) => i.isPending || i.isInProgress;

  static Duration? _average(Iterable<Duration?> durations) {
    final known = durations.whereType<Duration>().toList();
    if (known.isEmpty) return null;
    return Duration(seconds: known.fold<int>(0, (sum, d) => sum + d.inSeconds) ~/ known.length);
  }

  /// Every area with reports, busiest first.
  static List<AreaStats> byArea(List<IncidentEntity> incidents) {
    final groups = <String, List<IncidentEntity>>{};
    for (final i in incidents) {
      groups.putIfAbsent(areaOf(i), () => []).add(i);
    }
    final rows = [
      for (final MapEntry(key: area, value: reports) in groups.entries)
        AreaStats(
          area: area,
          total: reports.length,
          open: reports.where(_open).length,
          critical: reports
              .where((i) => IncidentTriageHelper.getUrgencyWeight(i.urgencyStatus) >= 4)
              .length,
          topCategory: _mostCommon(reports.map((i) => i.category)),
          resolvedShare: reports.where((i) => i.isSolved).length / reports.length,
          avgTimeToRespond: _average(reports.map((i) => i.timeToRespond)),
          avgTimeToResolve: _average(reports.map((i) => i.timeToResolve)),
          avgRating: () {
            final ratings = reports.map((i) => i.rating).whereType<int>().toList();
            return ratings.isEmpty ? null : ratings.reduce((a, b) => a + b) / ratings.length;
          }(),
        ),
    ]..sort((a, b) => b.total != a.total ? b.total.compareTo(a.total) : a.area.compareTo(b.area));
    return rows;
  }

  /// Each department's reports (a report counts for every department it
  /// goes to), in Department order.
  static List<DepartmentStats> byDepartment(List<IncidentEntity> incidents) {
    return [
      for (final department in Department.values)
        () {
          final reports = incidents.where((i) => i.departments.contains(department)).toList();
          return DepartmentStats(
            department: department,
            total: reports.length,
            open: reports.where(_open).length,
            unassigned: reports.where((i) => _open(i) && i.assignedResponderId == null).length,
            avgTimeToRespond: _average(reports.map((i) => i.timeToRespond)),
          );
        }(),
    ];
  }

  static String _mostCommon(Iterable<String> values) {
    final counts = <String, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    if (counts.isEmpty) return '—';
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}
