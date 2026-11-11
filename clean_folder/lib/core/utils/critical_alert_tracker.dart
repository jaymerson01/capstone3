import 'package:community_safety_app/core/utils/incident_triage_helper.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

/// Picks the reports that should raise an alert (the admin's pop-up, a
/// resident's nearby warning): critical and still open, each once. A report
/// alerts when it arrives while the app is open (or shortly before it was
/// opened), or when an older one turns critical, for example from
/// neighbours' "Me Too" votes.
class CriticalAlertTracker {
  CriticalAlertTracker({DateTime? openedAt}) : _openedAt = openedAt ?? DateTime.now();

  /// Critical reports filed this long before the desk opened still pop up.
  static const Duration recentWindow = Duration(minutes: 10);

  final DateTime _openedAt;
  final Set<String> _handled = {};
  final Set<String> _seenNotCritical = {};

  static bool isCriticalAndOpen(IncidentEntity incident) =>
      (incident.isPending || incident.isInProgress) &&
      IncidentTriageHelper.calculateEffectiveUrgency(
            category: incident.category,
            upvoteCount: incident.upvoteCount,
            currentUrgency: incident.urgencyStatus,
          ) ==
          'CRITICAL';

  /// The reports in [incidents] to pop up now, oldest first.
  List<IncidentEntity> take(List<IncidentEntity> incidents) {
    final alerts = <IncidentEntity>[];
    for (final incident in incidents) {
      if (!isCriticalAndOpen(incident)) {
        _seenNotCritical.add(incident.id);
        continue;
      }
      if (!_handled.add(incident.id)) continue;
      final recent = incident.timestamp.isAfter(_openedAt.subtract(recentWindow));
      if (recent || _seenNotCritical.contains(incident.id)) alerts.add(incident);
    }
    alerts.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return alerts;
  }
}
