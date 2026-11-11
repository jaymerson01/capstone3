import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/utils/critical_alert_tracker.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

/// The desk's to-do counts, from the live reports.
class AttentionCounts {
  const AttentionCounts({
    required this.criticalOpen,
    required this.waitingForResponder,
    required this.respondersOnTheWay,
    required this.idChecks,
  });

  factory AttentionCounts.from(List<IncidentEntity> incidents, {required int idChecks}) {
    bool open(IncidentEntity i) => i.isPending || i.isInProgress;
    return AttentionCounts(
      criticalOpen: incidents.where(CriticalAlertTracker.isCriticalAndOpen).length,
      waitingForResponder: incidents.where((i) => open(i) && i.assignedResponderId == null).length,
      respondersOnTheWay: incidents.where((i) => open(i) && i.responderStatus == 'on_the_way').length,
      idChecks: idChecks,
    );
  }

  final int criticalOpen;
  final int waitingForResponder;
  final int respondersOnTheWay;
  final int idChecks;
}

/// "Needs attention": what the admin should act on now, each card opening
/// the page where they act on it.
class AdminAttentionRow extends StatelessWidget {
  const AdminAttentionRow({
    super.key,
    required this.counts,
    required this.onOpenReports,
    required this.onOpenMap,
    required this.onOpenCitizens,
  });

  final AttentionCounts counts;
  final VoidCallback onOpenReports;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenCitizens;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _AttentionCard(
        icon: Icons.emergency_rounded,
        tone: AdminTone.red,
        count: counts.criticalOpen,
        label: 'Critical and still open',
        action: 'Incident reports',
        onTap: onOpenReports,
      ),
      _AttentionCard(
        icon: Icons.person_search_rounded,
        tone: AdminTone.orange,
        count: counts.waitingForResponder,
        label: 'Waiting for a responder',
        action: 'Assign one',
        onTap: onOpenReports,
      ),
      _AttentionCard(
        icon: Icons.directions_run_rounded,
        tone: AdminTone.cyan,
        count: counts.respondersOnTheWay,
        label: 'Responders on the way',
        action: 'Dispatch map',
        onTap: onOpenMap,
      ),
      _AttentionCard(
        icon: Icons.badge_rounded,
        tone: AdminTone.yellow,
        count: counts.idChecks,
        label: 'IDs to check',
        action: 'Citizen directory',
        onTap: onOpenCitizens,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NEEDS ATTENTION',
          style: TextStyle(color: AdminColors.textHint, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000 ? 4 : (constraints.maxWidth >= 520 ? 2 : 1);
            const gap = 14.0;
            final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [for (final card in cards) SizedBox(width: width, child: card)],
            );
          },
        ),
      ],
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    required this.icon,
    required this.tone,
    required this.count,
    required this.label,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final AdminTone tone;
  final int count;
  final String label;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AdminPanel(
          padding: const EdgeInsets.all(16),
          radius: 20,
          accent: active ? tone.base : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AdminIconTile(icon: icon, tone: active ? tone : AdminTone.slate, size: 40),
                  const Spacer(),
                  Text(action, style: TextStyle(color: tone.text, fontSize: 12, fontWeight: FontWeight.w700)),
                  Icon(Icons.chevron_right_rounded, color: tone.text, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$count',
                style: TextStyle(
                  color: active ? AdminColors.textStrong : AdminColors.textHint,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AdminColors.textSoft, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
