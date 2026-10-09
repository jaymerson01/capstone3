import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:community_safety_app/core/presentation/widgets/in_app_evidence_player_dialog.dart';

import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';

import '../../domain/entities/incident_entity.dart';
import '../../data/models/incident_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/incident_bloc.dart';
import '../bloc/incident_state.dart';
import '../widgets/incident_status_timeline.dart';

class IncidentDetailPage extends StatelessWidget {
  final IncidentEntity initialIncident;

  const IncidentDetailPage({
    super.key,
    required this.initialIncident,
  });

  /// Allows opening incident details directly by Firestore document ID (e.g. from Push Notification tap)
  static Future<void> openById(BuildContext context, String incidentId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('incidents')
          .doc(incidentId)
          .get();
      if (doc.exists && context.mounted) {
        IncidentModel model = IncidentModel.fromFirestore(doc);
        // Contact details are only readable by the reporter and admins.
        try {
          final contact = await doc.reference
              .collection(IncidentModel.confidentialCollection)
              .doc(IncidentModel.confidentialDocId)
              .get();
          model = model.withConfidential(contact.data());
        } catch (_) {}
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IncidentDetailPage(initialIncident: model),
          ),
        );
      }
    } catch (e) {
      debugPrint("Could not open incident by ID: $e");
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'in progress':
      case 'progress':
      case 'inprogress':
        return AppColors.progress;
      case 'resolved':
      case 'resolved/solved':
      case 'solved':
      case 'resolve':
        return AppColors.solved;
      default:
        return AppColors.textLight;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final year = timestamp.year;
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidentBloc, IncidentState>(
      builder: (context, state) {
        IncidentEntity currentIncident = initialIncident;

        // Reactively locate the live version of this report from the stream
        if (state is IncidentLoaded) {
          try {
            final liveIncident = state.incidents.firstWhere(
              (inc) => inc.id == initialIncident.id,
            );
            currentIncident = liveIncident;
          } catch (_) {}
        }

        final statusColor = _getStatusColor(currentIncident.status);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.textDark),
            title: Text(
              currentIncident.category,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      currentIncident.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppColors.border, height: 1),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Sync Status Banner
                _buildSyncBanner(context, currentIncident),
                SizedBox(height: 16),

                // 2. Metadata & Complainant Header Card
                _buildMetadataCard(context, currentIncident),
                SizedBox(height: 16),

                // 2.1 On Behalf of Someone Else Card (if applicable)
                if (currentIncident.isReportingOnBehalf) ...[
                  _buildOnBehalfCard(context, currentIncident),
                  SizedBox(height: 16),
                ],

                // 3. Location & GPS Coordinates Block
                _buildLocationCard(context, currentIncident),
                SizedBox(height: 16),

                // 4. Resident Incident Description Block
                _buildDescriptionCard(context, currentIncident),
                SizedBox(height: 16),

                // 5. Official Dispatcher Remarks & Action Notes
                _buildDispatcherNotesCard(context, currentIncident),
                SizedBox(height: 16),

                // 6. Evidence Photo Block (with Tap-to-Zoom)
                _buildEvidenceCard(context, currentIncident),
                SizedBox(height: 20),

                // 7. Safety Action Protocol & Reactive Resolution Stage Timeline
                IncidentStatusTimeline(incident: currentIncident),
                SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Sync Status Banner ───────────────────────────────────────────────────────
  Widget _buildSyncBanner(BuildContext context, IncidentEntity incident) {
    final isSynced = incident.isSynced;
    final bannerColor = isSynced ? AppColors.solved : AppColors.pending;

    return Custom3dCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      glowColor: bannerColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bannerColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSynced ? Icons.cloud_done_rounded : Icons.cloud_queue_rounded,
              color: bannerColor,
              size: 24,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSynced
                      ? "Live at Command Center"
                      : "Stored Locally (Pending Cloud Sync)",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: bannerColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isSynced
                      ? "This report has been uploaded to the live cloud database and received by Barangay Moonwalk dispatchers."
                      : "This report is safely preserved in your phone's offline storage. It will automatically upload to dispatch once connected to the cloud server.",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Metadata & Complainant Card ─────────────────────────────────────────────
  Widget _buildMetadataCard(BuildContext context, IncidentEntity incident) {
    return Custom3dCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Incident ID: #${incident.id.isNotEmpty ? (incident.id.length > 8 ? incident.id.substring(0, 8).toUpperCase() : incident.id.toUpperCase()) : 'LOCAL'}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.access_time, size: 13, color: AppColors.textLight),
                  SizedBox(width: 4),
                  Text(
                    _formatTimestamp(incident.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            incident.category,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxBadgeWidth = constraints.maxWidth;
              return Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (incident.areaSector != null && incident.areaSector!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      constraints: BoxConstraints(maxWidth: maxBadgeWidth),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 13, color: AppColors.primary),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              incident.areaSector!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (incident.isReportingOnBehalf)
                    Builder(
                      builder: (context) {
                        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                        final isOwnFiling = currentUserId != null && currentUserId == incident.reporterId;
                        final displayVictimName = isOwnFiling
                            ? (incident.victimName?.isNotEmpty == true ? incident.victimName! : 'Relative')
                            : (incident.victimName?.isNotEmpty == true ? _maskName(incident.victimName) : 'Protected Resident');

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          constraints: BoxConstraints(maxWidth: maxBadgeWidth),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9500).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFF9500).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_alt_rounded,
                                  size: 13, color: Color(0xFFFF9500)),
                              SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  "For: $displayVictimName",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF9500),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  if (incident.estimatedResponseTime != null &&
                      incident.estimatedResponseTime!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      constraints: BoxConstraints(maxWidth: maxBadgeWidth),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 13, color: Color(0xFF00E5FF)),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              "ETA: ${incident.estimatedResponseTime!}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00E5FF),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    constraints: BoxConstraints(maxWidth: maxBadgeWidth),
                    decoration: BoxDecoration(
                      color: incident.isAnonymous
                          ? AppColors.pending.withValues(alpha: 0.12)
                          : AppColors.solved.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: incident.isAnonymous
                            ? AppColors.pending.withValues(alpha: 0.3)
                            : AppColors.solved.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          incident.isAnonymous
                              ? Icons.security_rounded
                              : Icons.person_outline_rounded,
                          size: 13,
                          color: incident.isAnonymous
                              ? AppColors.pending
                              : AppColors.solved,
                        ),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            incident.isAnonymous
                                ? "Anonymous Filing"
                                : (incident.reporterName?.isNotEmpty == true
                                    ? incident.reporterName!
                                    : "Registered Resident"),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: incident.isAnonymous
                                  ? AppColors.pending
                                  : AppColors.solved,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _maskName(String? name) {
    if (name == null || name.trim().isEmpty) return "Protected Resident";
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.map((part) {
      if (part.length <= 1) return part;
      return '${part[0]}${'•' * (part.length - 1)}';
    }).join(' ');
  }

  String _maskPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return "•••••••••••";
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 10) {
      final prefix = digits.substring(0, 4);
      final suffix = digits.substring(digits.length - 2);
      return "$prefix ••• ••$suffix";
    }
    return "•••••••••••";
  }

  // ── On-Behalf Victim Dossier Card (RA 10173 Compliant) ─────────────────────
  Widget _buildOnBehalfCard(BuildContext context, IncidentEntity incident) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnFiling = currentUserId != null && currentUserId == incident.reporterId;

    return Custom3dCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_alt_rounded,
                  color: Color(0xFFFF9500),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "REPORTED ON BEHALF",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF9500),
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (isOwnFiling)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.solved.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.solved.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              "Your Filing",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.solved,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_outlined, size: 10, color: AppColors.primary),
                                SizedBox(width: 3),
                                Text(
                                  "RA 10173 Protected",
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      isOwnFiling
                          ? "You filed this emergency report on behalf of your contact"
                          : "Off-Site Citizen Dispatch Filing (Anonymized for Public Safety)",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFF9500).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "On-Scene Affected Person / Relative:",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isOwnFiling
                      ? (incident.victimName?.isNotEmpty == true
                          ? incident.victimName!
                          : "Unspecified Name")
                      : _maskName(incident.victimName),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (incident.victimPhone != null &&
                    incident.victimPhone!.trim().isNotEmpty) ...[
                  Divider(color: AppColors.border, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Victim Contact Number:",
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            isOwnFiling
                                ? incident.victimPhone!
                                : _maskPhone(incident.victimPhone),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isOwnFiling ? AppColors.primary : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      if (isOwnFiling)
                        IconButton(
                          onPressed: () async {
                            final uri = Uri.parse("tel:${incident.victimPhone!.replaceAll(' ', '').trim()}");
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          icon: Icon(Icons.phone_in_talk_rounded, color: AppColors.solved),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.solved.withValues(alpha: 0.15),
                          ),
                          tooltip: "Call Victim On-Site",
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_rounded, size: 12, color: AppColors.textLight),
                              SizedBox(width: 4),
                              Text(
                                "Dispatcher Only",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                if (!isOwnFiling) ...[
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.privacy_tip_outlined, size: 14, color: Color(0xFF00E5FF)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "In compliance with RA 10173 (Data Privacy Act of 2012), contact info is masked for public viewing and restricted to authorized emergency responders.",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textLight,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Location & GPS Card ─────────────────────────────────────────────────────
  Widget _buildLocationCard(BuildContext context, IncidentEntity incident) {
    final locationText = BarangaySectorHelper.formatReadableAddress(
      resolvedAddress: incident.resolvedAddress,
      areaSector: incident.areaSector,
      latitude: incident.latitude,
      longitude: incident.longitude,
    );

    return Custom3dCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.location_on, color: AppColors.danger, size: 20),
              ),
              SizedBox(width: 10),
              Text(
                "Incident Pinned Location",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            locationText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gps_fixed, size: 12, color: AppColors.textLight),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "GPS: ${incident.latitude.toStringAsFixed(6)}, ${incident.longitude.toStringAsFixed(6)}",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Description Card ────────────────────────────────────────────────────────
  Widget _buildDescriptionCard(BuildContext context, IncidentEntity incident) {
    return Custom3dCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.description_outlined,
                    color: AppColors.primary, size: 20),
              ),
              SizedBox(width: 10),
              Text(
                "Incident Narrative",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            incident.description.isNotEmpty
                ? incident.description
                : "No description provided.",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Dispatcher Remarks & Action Notes ───────────────────────────────────────
  Widget _buildDispatcherNotesCard(BuildContext context, IncidentEntity incident) {
    final hasNotes = incident.dispatcherNotes != null &&
        incident.dispatcherNotes!.trim().isNotEmpty;

    return Custom3dCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      glowColor: hasNotes ? AppColors.progress : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (hasNotes ? AppColors.progress : AppColors.textLight)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: hasNotes ? AppColors.progress : AppColors.textLight,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                hasNotes
                    ? "Dispatcher Remarks & Action Notes"
                    : "Command Center Status",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (incident.estimatedResponseTime != null &&
              incident.estimatedResponseTime!.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.timer_outlined,
                        color: Color(0xFF00E5FF), size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "RESPONDERS DISPATCHED • ESTIMATED ARRIVAL",
                          style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          incident.estimatedResponseTime!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasNotes) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.progress.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.progress.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                incident.dispatcherNotes!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textDark,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            Text(
              "Awaiting dispatcher evaluation. Updates, dispatched emergency units, or field verification remarks will be displayed here in real time.",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Evidence Card with Tap-to-Zoom & Video Playback ──────────────────────────
  Widget _buildEvidenceCard(BuildContext context, IncidentEntity incident) {
    final photoUrl = incident.photoUrl;
    final videoUrl = incident.videoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final hasVideo = videoUrl != null && videoUrl.isNotEmpty;

    if (!hasPhoto && !hasVideo) {
      return Custom3dCard(
        padding: const EdgeInsets.all(18),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.attachment_rounded,
                      color: AppColors.primary, size: 20),
                ),
                SizedBox(width: 10),
                Text(
                  "Evidence Attachment",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.perm_media_outlined,
                      size: 28, color: AppColors.textLight),
                  SizedBox(height: 6),
                  Text(
                    "No media evidence attached to this report",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Custom3dCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
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
                    child: Icon(Icons.perm_media_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Verified Evidence",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              if (hasPhoto)
                Text(
                  "Tap photo to zoom",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (hasPhoto) ...[
            SizedBox(height: 14),
            GestureDetector(
              onTap: () => _openPhotoZoomDialog(context, photoUrl),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _buildImageWidget(photoUrl, height: 210),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasVideo) ...[
            SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.progress.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.progress.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.progress.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.videocam_rounded,
                            color: AppColors.progress, size: 20),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Emergency Video Evidence",
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Low-latency clip verified by responder network",
                              style: TextStyle(
                                color: AppColors.progress,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.progress,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        InAppEvidencePlayerDialog.show(
                          context,
                          videoUrl: videoUrl,
                          title: "${initialIncident.category} Evidence",
                        );
                      },
                      icon: Icon(Icons.play_circle_fill_rounded, size: 20),
                      label: Text(
                        "Watch Evidence Video Stream",
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageWidget(String pathOrUrl, {double? height}) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Image.network(
        pathOrUrl,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageErrorBlock(height),
      );
    }

    final localPath = pathOrUrl.replaceFirst('file://', '');
    return Image.file(
      File(localPath),
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImageErrorBlock(height),
    );
  }

  Widget _buildImageErrorBlock(double? height) {
    return Container(
      width: double.infinity,
      height: height ?? 140,
      color: AppColors.surfaceLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 36, color: AppColors.textLight),
          SizedBox(height: 6),
          Text(
            "Evidence photo stored locally (pending upload)",
            style: TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  void _openPhotoZoomDialog(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: _buildImageWidget(photoUrl),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
