import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';

import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/core/presentation/widgets/in_app_evidence_player_dialog.dart';
import 'package:community_safety_app/core/presentation/widgets/in_app_image_viewer_dialog.dart';
import '../widgets/admin_ui.dart';
import '../widgets/stat_card.dart';
import '../widgets/custom_line_chart.dart';
import '../widgets/custom_pie_chart.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';

class AdminDashboardPage extends StatefulWidget {
  final VoidCallback? onViewAllReports;

  const AdminDashboardPage({super.key, this.onViewAllReports});

  /// The pill colour for a stored report status. The admin portal saves
  /// "in_progress", so underscores count as spaces.
  @visibleForTesting
  static AdminTone statusTone(String status) {
    switch (status.toLowerCase().replaceAll('_', ' ')) {
      case 'solved':
      case 'resolved':
        return AdminTone.green;
      case 'inprogress':
      case 'in progress':
      case 'responding':
        return AdminTone.blue;
      case 'spam':
        return AdminTone.slate;
      default:
        return AdminTone.yellow;
    }
  }

  /// The pill text for a stored report status, e.g. "IN PROGRESS".
  @visibleForTesting
  static String statusLabel(String status) =>
      status.replaceAll('_', ' ').toUpperCase();

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1100;
    final bool isTablet = screenWidth >= 700 && screenWidth < 1100;

    return BlocBuilder<IncidentBloc, IncidentState>(
      builder: (context, state) {
        final List<IncidentEntity> incidents = state is IncidentLoaded
            ? state.incidents
            : [];

        final int totalIncidents = incidents.length;
        final int solvedCases = incidents.where((i) => i.isSolved).length;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('broadcasts')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, broadcastSnapshot) {
            final int activeSirens =
                broadcastSnapshot.hasData ? broadcastSnapshot.data!.docs.length : 0;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, usersSnapshot) {
                final int registeredUsers =
                    usersSnapshot.hasData ? usersSnapshot.data!.docs.length : 0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(screenWidth >= 700 ? 28 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Welcome Header ──────────────────────────────────────
                      _buildWelcomeHeader(),
                      SizedBox(height: 24),

                      // ── Live Stat Cards ──────────────────────────────────────
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 124,
                        ),
                        children: [
                          StatCard(
                            title: "Incident Reports",
                            value: totalIncidents.toString(),
                            icon: Icons.description_outlined,
                            backgroundColor: AdminColors.primary,
                          ),
                          StatCard(
                            title: "Active Sirens",
                            value: activeSirens.toString(),
                            icon: Icons.campaign_rounded,
                            backgroundColor: activeSirens > 0
                                ? AdminColors.danger
                                : AdminColors.borderHighlight,
                            highlight: activeSirens > 0,
                          ),
                          StatCard(
                            title: "Solved Cases",
                            value: solvedCases.toString(),
                            icon: Icons.check_rounded,
                            backgroundColor: AdminColors.success,
                          ),
                          StatCard(
                            title: "Registered Citizens",
                            value: registeredUsers.toString(),
                            icon: Icons.people_alt_outlined,
                            backgroundColor: AdminColors.cyan,
                          ),
                        ],
                      ),
                      SizedBox(height: 22),

                      // ── Charts ──────────────────────────────────────────────
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: CustomLineChart(incidents: incidents),
                            ),
                            SizedBox(width: 18),
                            Expanded(
                              flex: 4,
                              child: CustomPieChart(incidents: incidents),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomLineChart(incidents: incidents),
                            SizedBox(height: 18),
                            CustomPieChart(incidents: incidents),
                          ],
                        ),

                      SizedBox(height: 22),

                      // ── Recent Urgent Incidents Table ───────────────────────
                      _buildRecentIncidentsCard(context, incidents),
                      SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeHeader() {
    final now = DateTime.now();
    return AdminPageTitle(
      title: "Barangay Moonwalk Command Center",
      subtitle:
          "Real-time community safety dispatch, municipal alerts, and telemetry overview.",
      trailing: [
        // Live status pill
        const AdminLiveBadge(
          label: "Command Center Online · Live Firestore Sync",
        ),
        // Date badge
        Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AdminIconTile(
                icon: Icons.calendar_today_outlined,
                tone: AdminTone.blue,
                size: 34,
              ),
              SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${now.day}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textStrong,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    _monthName(now.month),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AdminColors.textLight,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentIncidentsCard(
    BuildContext context,
    List<IncidentEntity> incidents,
  ) {
    // Sort descending by timestamp and take top 5
    final recentList = List<IncidentEntity>.from(incidents)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final displayList = recentList.take(5).toList();

    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionTitle(
            icon: Icons.bolt_outlined,
            tone: AdminTone.cyan,
            title: "Recent Community Incidents",
            subtitle: "Live stream of latest incoming citizen emergency reports",
          ),
          SizedBox(height: 16),

          if (displayList.isEmpty)
            const Center(
              child: AdminEmptyState(
                icon: Icons.check_circle_outline,
                title: "No active or pending incident reports",
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayList.length,
              separatorBuilder: (context, index) => SizedBox(height: 10),
              itemBuilder: (context, index) {
                final incident = displayList[index];
                return _IncidentListItem(
                  incident: incident,
                  onTap: () => _showIncidentDetailModal(context, incident),
                );
              },
            ),
          SizedBox(height: 12),
          TextButton(
            onPressed: widget.onViewAllReports,
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.hovered)
                    ? AdminColors.textStrong
                    : AdminColors.primaryText,
              ),
              overlayColor: WidgetStatePropertyAll(
                AdminColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    "View All in Dispatch",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showIncidentDetailModal(BuildContext context, IncidentEntity inc) {
    final statusTone = _statusTone(inc.status);
    final isUrgent = _isUrgent(inc);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AdminDialog(
          // Top Title & Close
          icon: _categoryIcon(inc.category),
          tone: statusTone,
          title: inc.category,
          subtitle:
              "Report ID: ${inc.id.length > 10 ? inc.id.substring(0, 10) : inc.id}",
          onClose: () => Navigator.pop(dialogCtx),
          maxWidth: 540,
          // Action buttons
          actions: [
            AdminButton(
              label: "Close",
              style: AdminButtonStyle.ghost,
              onPressed: () => Navigator.pop(dialogCtx),
            ),
            AdminButton(
              label: "Manage in Dispatch",
              icon: Icons.open_in_new,
              onPressed: () {
                Navigator.pop(dialogCtx);
                if (widget.onViewAllReports != null) {
                  widget.onViewAllReports!();
                }
              },
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Urgency and Status Tags
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AdminPill(
                          label: AdminDashboardPage.statusLabel(inc.status),
                          tone: statusTone,
                        ),
                        if (isUrgent)
                          const AdminPill(
                            label: "HIGH PRIORITY",
                            tone: AdminTone.red,
                            solid: true,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "${inc.upvoteCount} Corroborated",
                    style: const TextStyle(
                      color: AdminColors.cyanText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18),

              // Description
              const AdminFieldLabel("Citizen Description"),
              SizedBox(
                width: double.infinity,
                child: AdminInset(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    inc.description.isEmpty
                        ? "No narrative provided."
                        : inc.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AdminColors.textDark,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),

              // Location & Reporter Details
              SizedBox(
                width: double.infinity,
                child: AdminInset(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _modalDetailRow(
                        Icons.location_on_outlined,
                        "Location",
                        inc.resolvedAddress ??
                            inc.areaSector ??
                            "GPS (${inc.latitude.toStringAsFixed(4)}, ${inc.longitude.toStringAsFixed(4)})",
                      ),
                      SizedBox(height: 10),
                      _modalDetailRow(
                        Icons.person_outline,
                        "Reporter",
                        inc.isAnonymous
                            ? "Anonymous Citizen"
                            : (inc.reporterName ?? inc.reporterEmail ?? inc.reporterId),
                      ),
                      SizedBox(height: 10),
                      _modalDetailRow(
                        Icons.access_time_rounded,
                        "Reported At",
                        "${inc.timestamp.day}/${inc.timestamp.month}/${inc.timestamp.year} ${inc.timestamp.hour.toString().padLeft(2, '0')}:${inc.timestamp.minute.toString().padLeft(2, '0')}",
                      ),
                    ],
                  ),
                ),
              ),

              // Evidence preview if present
              if (inc.photoUrl != null && inc.photoUrl!.isNotEmpty) ...[
                SizedBox(height: 18),
                const AdminFieldLabel("Photo Evidence"),
                GestureDetector(
                  onTap: () {
                    InAppImageViewerDialog.show(
                      context,
                      imageUrl: inc.photoUrl!,
                      title: "Incident #${inc.id.substring(0, inc.id.length > 8 ? 8 : inc.id.length)} Photo Evidence",
                    );
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Tooltip(
                      message: "Click to open full resolution viewer",
                      child: Container(
                        foregroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            inc.photoUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) {
                              return Container(
                                height: 80,
                                color: AdminColors.well,
                                alignment: Alignment.center,
                                child: Text(
                                  "Unable to load evidence image",
                                  style: TextStyle(
                                    color: AdminColors.textLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              if (inc.videoUrl != null && inc.videoUrl!.isNotEmpty) ...[
                SizedBox(height: 18),
                const AdminFieldLabel("Video Evidence"),
                AdminInset(
                  tone: AdminTone.blue,
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Row(
                    children: [
                      const AdminIconTile(
                        icon: Icons.videocam_rounded,
                        tone: AdminTone.blue,
                        size: 34,
                      ),
                      SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Video Recording Attached",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AdminColors.textStrong,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      AdminButton(
                        label: "Play In-App",
                        icon: Icons.play_arrow_rounded,
                        height: 38,
                        onPressed: () {
                          InAppEvidencePlayerDialog.show(
                            context,
                            videoUrl: inc.videoUrl!,
                            title: "Incident #${inc.id.substring(0, inc.id.length > 8 ? 8 : inc.id.length)} Video Evidence",
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],

              if (inc.dispatcherNotes != null &&
                  inc.dispatcherNotes!.isNotEmpty) ...[
                SizedBox(height: 18),
                const AdminFieldLabel("Dispatcher Remarks"),
                SizedBox(
                  width: double.infinity,
                  child: AdminInset(
                    tone: AdminTone.cyan,
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      inc.dispatcherNotes!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AdminColors.textDark,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }

  Widget _modalDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AdminColors.textHint),
        SizedBox(width: 10),
        Text(
          "$title: ",
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AdminColors.textHint,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static IconData _categoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('fire')) return Icons.local_fire_department_rounded;
    if (cat.contains('medic')) return Icons.medical_services_rounded;
    if (cat.contains('theft') || cat.contains('rob')) return Icons.shield_outlined;
    if (cat.contains('flood')) return Icons.water_damage_rounded;
    if (cat.contains('accident')) return Icons.car_crash_rounded;
    if (cat.contains('violenc') || cat.contains('fight')) return Icons.sports_kabaddi_rounded;
    return Icons.warning_amber_rounded;
  }

  static AdminTone _statusTone(String status) =>
      AdminDashboardPage.statusTone(status);

  static bool _isUrgent(IncidentEntity inc) {
    return (inc.urgencyStatus ?? '').toLowerCase() == 'critical' ||
        (inc.urgencyStatus ?? '').toLowerCase() == 'high';
  }

  static String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

class _IncidentListItem extends StatefulWidget {
  final IncidentEntity incident;
  final VoidCallback onTap;

  const _IncidentListItem({required this.incident, required this.onTap});

  @override
  State<_IncidentListItem> createState() => _IncidentListItemState();
}

class _IncidentListItemState extends State<_IncidentListItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final inc = widget.incident;
    final statusTone = _AdminDashboardPageState._statusTone(inc.status);
    final bool isUrgent = _AdminDashboardPageState._isUrgent(inc);
    final date = inc.timestamp;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovered
                ? (isUrgent ? AdminColors.critical : AdminColors.primary)
                      .withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: AdminInset(
            tone: isUrgent ? AdminTone.red : null,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AdminIconTile(
                  icon: _AdminDashboardPageState._categoryIcon(inc.category),
                  tone: statusTone,
                  size: 40,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${inc.category} — ${BarangaySectorHelper.normalizeSector(inc.areaSector, inc.resolvedAddress)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AdminColors.textStrong,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        "By ${inc.isAnonymous ? 'Anonymous' : (inc.reporterName ?? 'Citizen')} · ${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AdminColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: AdminPill(
                    label: AdminDashboardPage.statusLabel(inc.status),
                    tone: statusTone,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
