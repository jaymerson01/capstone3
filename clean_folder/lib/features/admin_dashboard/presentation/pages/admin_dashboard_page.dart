import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';

import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/core/presentation/widgets/in_app_evidence_player_dialog.dart';
import 'package:community_safety_app/core/presentation/widgets/in_app_image_viewer_dialog.dart';
import '../widgets/stat_card.dart';
import '../widgets/custom_line_chart.dart';
import '../widgets/custom_pie_chart.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';

class AdminDashboardPage extends StatefulWidget {
  final VoidCallback? onViewAllReports;

  const AdminDashboardPage({super.key, this.onViewAllReports});

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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Welcome Header ──────────────────────────────────────
                      _buildWelcomeHeader(),
                      SizedBox(height: 28),

                      // ── Live Stat Cards ──────────────────────────────────────
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          StatCard(
                            title: "Incident Reports",
                            value: totalIncidents.toString(),
                            icon: Icons.warning_amber_rounded,
                            backgroundColor: AdminColors.primary,
                          ),
                          StatCard(
                            title: "Active Sirens",
                            value: activeSirens.toString(),
                            icon: Icons.emergency_share_rounded,
                            backgroundColor: activeSirens > 0
                                ? AdminColors.danger
                                : AdminColors.borderHighlight,
                          ),
                          StatCard(
                            title: "Solved Cases",
                            value: solvedCases.toString(),
                            icon: Icons.check_circle_outline,
                            backgroundColor: AdminColors.success,
                          ),
                          StatCard(
                            title: "Registered Citizens",
                            value: registeredUsers.toString(),
                            icon: Icons.people_alt_outlined,
                            backgroundColor: AdminColors.violet,
                          ),
                        ],
                      ),
                      SizedBox(height: 28),

                      // ── Charts ──────────────────────────────────────────────
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: CustomLineChart(incidents: incidents),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              flex: 4,
                              child: CustomPieChart(incidents: incidents),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            CustomLineChart(incidents: incidents),
                            SizedBox(height: 20),
                            CustomPieChart(incidents: incidents),
                          ],
                        ),

                      SizedBox(height: 28),

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
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AdminColors.surfaceDeep, AdminColors.heroEnd],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Barangay Moonwalk Command Center",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Real-time community safety dispatch, municipal alerts, and telemetry overview.",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),
                // Live status pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.solved.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.solved.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.solved,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.solved.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 7),
                      Text(
                        "Command Center Online · Live Firestore Sync",
                        style: TextStyle(
                          color: AppColors.solved,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20),
          // Date badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(height: 6),
                Text(
                  "${now.day}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  _monthName(now.month),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

    return Custom3dCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 22,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.bolt_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recent Community Incidents",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Live stream of latest incoming citizen emergency reports",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: widget.onViewAllReports,
                icon: Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: AppColors.primary,
                ),
                label: Text(
                  "View All in Dispatch",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(height: 1, color: AppColors.border),
          SizedBox(height: 12),

          if (displayList.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AdminColors.success.withValues(alpha: 0.5),
                    size: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No active or pending incident reports",
                    style: TextStyle(
                      color: AdminColors.textLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayList.length,
              separatorBuilder: (context, index) => Container(
                height: 1,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
              itemBuilder: (context, index) {
                final incident = displayList[index];
                return _IncidentListItem(
                  incident: incident,
                  onTap: () => _showIncidentDetailModal(context, incident),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showIncidentDetailModal(BuildContext context, IncidentEntity inc) {
    final statusColor = _statusColor(inc.status);
    final isUrgent = (inc.urgencyStatus ?? '').toLowerCase() == 'critical' ||
        (inc.urgencyStatus ?? '').toLowerCase() == 'high';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: AdminColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AdminColors.border),
          ),
          child: Container(
            width: 540,
            padding: const EdgeInsets.all(26),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Title & Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _categoryIcon(inc.category),
                              color: statusColor,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inc.category,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AdminColors.textDark,
                                ),
                              ),
                              Text(
                                "Report ID: ${inc.id.length > 10 ? inc.id.substring(0, 10) : inc.id}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AdminColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AdminColors.textLight),
                        onPressed: () => Navigator.pop(dialogCtx),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  Divider(color: AdminColors.border),
                  SizedBox(height: 14),

                  // Urgency and Status Tags
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          inc.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      if (isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AdminColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  AdminColors.danger.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            "HIGH PRIORITY",
                            style: TextStyle(
                              color: AdminColors.danger,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        "${inc.upvoteCount} Corroborated",
                        style: const TextStyle(
                          color: AdminColors.cyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    "Citizen Description",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.textLight,
                    ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: Text(
                      inc.description.isEmpty
                          ? "No narrative provided."
                          : inc.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AdminColors.textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),

                  // Location & Reporter Details
                  _modalDetailRow(
                    Icons.location_on_outlined,
                    "Location",
                    inc.resolvedAddress ??
                        inc.areaSector ??
                        "GPS (${inc.latitude.toStringAsFixed(4)}, ${inc.longitude.toStringAsFixed(4)})",
                  ),
                  SizedBox(height: 8),
                  _modalDetailRow(
                    Icons.person_outline,
                    "Reporter",
                    inc.isAnonymous
                        ? "Anonymous Citizen"
                        : (inc.reporterName ?? inc.reporterEmail ?? inc.reporterId),
                  ),
                  SizedBox(height: 8),
                  _modalDetailRow(
                    Icons.access_time_rounded,
                    "Reported At",
                    "${inc.timestamp.day}/${inc.timestamp.month}/${inc.timestamp.year} ${inc.timestamp.hour.toString().padLeft(2, '0')}:${inc.timestamp.minute.toString().padLeft(2, '0')}",
                  ),

                  // Evidence preview if present
                  if (inc.photoUrl != null && inc.photoUrl!.isNotEmpty) ...[
                    SizedBox(height: 14),
                    Text(
                      "Photo Evidence",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.textLight,
                      ),
                    ),
                    SizedBox(height: 8),
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              inc.photoUrl!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) {
                                return Container(
                                  height: 80,
                                  color: AdminColors.background,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Unable to load evidence image",
                                    style: TextStyle(
                                      color: AdminColors.textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (inc.videoUrl != null && inc.videoUrl!.isNotEmpty) ...[
                    SizedBox(height: 14),
                    Text(
                      "Video Evidence",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.textLight,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AdminColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.videocam_rounded, color: AdminColors.primary, size: 22),
                          SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "Video Recording Attached",
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: Icon(Icons.play_arrow_rounded, size: 16),
                            label: Text("Play In-App", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                    SizedBox(height: 14),
                    Text(
                      "Dispatcher Remarks",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.cyan,
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AdminColors.cyan.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AdminColors.cyan.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        inc.dispatcherNotes!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AdminColors.textDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 22),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: Text(
                          "Close",
                          style: TextStyle(color: AdminColors.textLight),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          if (widget.onViewAllReports != null) {
                            widget.onViewAllReports!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: Text(
                          "Manage in Dispatch",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _modalDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AdminColors.textLight),
        SizedBox(width: 8),
        Text(
          "$title: ",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AdminColors.textLight,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AdminColors.textDark,
            ),
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

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'solved':
      case 'resolved':
        return AdminColors.success;
      case 'inprogress':
      case 'in progress':
      case 'responding':
        return AdminColors.cyan;
      case 'spam':
        return AdminColors.critical;
      default:
        return AdminColors.amber;
    }
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
    final statusClr = _AdminDashboardPageState._statusColor(inc.status);
    final date = inc.timestamp;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusClr.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusClr.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _AdminDashboardPageState._categoryIcon(inc.category),
                  color: statusClr,
                  size: 19,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${inc.category} — ${BarangaySectorHelper.normalizeSector(inc.areaSector, inc.resolvedAddress)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3),
                    Text(
                      "By ${inc.isAnonymous ? 'Anonymous' : (inc.reporterName ?? 'Citizen')} · ${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusClr.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusClr.withValues(alpha: 0.3)),
                ),
                child: Text(
                  inc.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusClr,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
