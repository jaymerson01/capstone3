import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/utils/incident_triage_helper.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

/// Picks the reports that should pop up on the admin's screen: critical and
/// still open, each once. A report pops up when it arrives while the desk is
/// open (or shortly before it was opened), or when an older one turns
/// critical, for example from neighbours' "Me Too" votes.
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

/// The pop-up itself. Resolves to true when the admin chooses to open the
/// incident reports.
Future<bool> showCriticalIncidentAlert(BuildContext context, IncidentEntity incident) async {
  final where = incident.areaSector ?? incident.resolvedAddress ?? 'Barangay Moonwalk';
  final opened = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: AdminColors.dangerDeep.withValues(alpha: 0.35),
    builder: (ctx) => AdminDialog(
      title: 'CRITICAL INCIDENT',
      subtitle: incident.category,
      icon: Icons.emergency_rounded,
      tone: AdminTone.red,
      maxWidth: 500,
      actions: [
        AdminButton(
          label: 'Dismiss',
          style: AdminButtonStyle.ghost,
          onPressed: () => Navigator.pop(ctx, false),
        ),
        AdminButton(
          label: 'Open report',
          icon: Icons.open_in_new_rounded,
          style: AdminButtonStyle.danger,
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminDetailRow(label: 'Where', value: where),
          AdminDetailRow(label: 'Reported', value: DateFormat('MMM d, h:mm a').format(incident.timestamp)),
          if (incident.ticketNumber.isNotEmpty) AdminDetailRow(label: 'Ticket', value: incident.ticketNumber),
          if (incident.upvoteCount > 0)
            AdminDetailRow(label: 'Confirmed by', value: '${incident.upvoteCount} neighbour(s)'),
          const SizedBox(height: 10),
          Text(
            incident.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AdminColors.textBody, fontSize: 13.5, height: 1.5),
          ),
        ],
      ),
    ),
  );
  return opened ?? false;
}
