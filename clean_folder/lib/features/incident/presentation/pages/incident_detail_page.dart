import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/neo/aurora_background.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/live_indicator.dart';
import 'package:community_safety_app/core/presentation/neo/neo_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_icon_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_status_pill.dart';
import 'package:community_safety_app/core/presentation/neo/neo_surface.dart';
import 'package:community_safety_app/core/presentation/neo/neo_tag.dart';
import 'package:community_safety_app/core/presentation/neo/neo_tray.dart';
import 'package:community_safety_app/core/presentation/widgets/in_app_evidence_player_dialog.dart';

import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';

import '../../domain/entities/incident_entity.dart';
import '../../data/models/incident_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/incident_bloc.dart';
import '../bloc/incident_state.dart';
import '../widgets/incident_status_timeline.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';
import 'package:community_safety_app/core/utils/localized_labels.dart';

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
    // Stored values may use "in_progress" as well as "In Progress".
    switch (status.toLowerCase().replaceAll('_', ' ')) {
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

        return AuroraBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  32 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header: category, report ID and time, status
                    _buildHeader(context, currentIncident, statusColor),
                    SizedBox(height: 14),

                    // 2. Sector, who filed it and the responders' ETA
                    _buildFactTags(context, currentIncident),
                    SizedBox(height: 18),

                    // 3. Command center: sync status, dispatch and dispatcher remarks
                    _buildCommandCenterCard(context, currentIncident),
                    SizedBox(height: 16),

                    // 4. Resolution stage and safety action protocol
                    IncidentStatusTimeline(incident: currentIncident),
                    SizedBox(height: 16),

                    // 5. On Behalf of Someone Else Card (if applicable)
                    if (currentIncident.isReportingOnBehalf) ...[
                      _buildOnBehalfCard(context, currentIncident),
                      SizedBox(height: 16),
                    ],

                    // 6. Location & GPS Coordinates Block
                    _buildLocationCard(context, currentIncident),
                    SizedBox(height: 16),

                    // 7. Resident Incident Description Block
                    _buildNarrativeCard(context, currentIncident),
                    SizedBox(height: 16),

                    // 8. Evidence Photo Block (with Tap-to-Zoom)
                    _buildEvidenceCard(context, currentIncident),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    IncidentEntity incident,
    Color statusColor,
  ) {
    final l10n = AppLocalizations.of(context);
    final shortId = incident.id.isNotEmpty
        ? (incident.id.length > 8
            ? incident.id.substring(0, 8).toUpperCase()
            : incident.id.toUpperCase())
        : l10n.detailLocalId;

    return Row(
      children: [
        NeoIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: l10n.commonBack,
          onPressed: () => Navigator.maybePop(context),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizedLabels.category(context, incident.category),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '${l10n.detailIncidentId(shortId)} · ${_formatTimestamp(incident.timestamp)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        NeoStatusPill(
          label: LocalizedLabels.status(context, incident.status).toUpperCase(),
          color: statusColor,
        ),
      ],
    );
  }

  // ── Fact Tags: sector, on-behalf, ETA, blotter, who filed ────────────────────
  Widget _buildFactTags(BuildContext context, IncidentEntity incident) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (incident.areaSector != null && incident.areaSector!.isNotEmpty)
          NeoTag(
            icon: Icons.location_on_rounded,
            label: incident.areaSector!,
            color: AppColors.primary,
          ),
        if (incident.isReportingOnBehalf)
          Builder(
            builder: (context) {
              final currentUserId = FirebaseAuth.instance.currentUser?.uid;
              final isOwnFiling = currentUserId != null && currentUserId == incident.reporterId;
              final displayVictimName = isOwnFiling
                  ? (incident.victimName?.isNotEmpty == true ? incident.victimName! : l10n.commonRelative)
                  : (incident.victimName?.isNotEmpty == true ? _maskName(context, incident.victimName) : l10n.detailProtectedResident);

              return NeoTag(
                icon: Icons.people_alt_rounded,
                label: l10n.reportForPerson(displayVictimName),
                color: AppColors.onBehalf,
              );
            },
          ),
        if (incident.estimatedResponseTime != null &&
            incident.estimatedResponseTime!.isNotEmpty)
          NeoTag(
            icon: Icons.timer_outlined,
            label: l10n.commonEta(incident.estimatedResponseTime!),
            color: AppColors.secondary,
          ),
        if (incident.isBlotter)
          NeoTag(
            icon: Icons.gavel_rounded,
            label: l10n.commonBlotterEntry,
            color: AppColors.blotter,
          ),
        NeoTag(
          icon: incident.isAnonymous
              ? Icons.security_rounded
              : Icons.person_outline_rounded,
          label: incident.isAnonymous
              ? l10n.detailAnonymousFiling
              : (incident.reporterName?.isNotEmpty == true
                  ? incident.reporterName!
                  : l10n.detailRegisteredResident),
          color: incident.isAnonymous ? AppColors.pending : AppColors.solved,
        ),
      ],
    );
  }

  String _maskName(BuildContext context, String? name) {
    if (name == null || name.trim().isEmpty) return AppLocalizations.of(context).detailProtectedResident;
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

  // ── Command Center: sync status, dispatch and dispatcher remarks ────────────
  Widget _buildCommandCenterCard(BuildContext context, IncidentEntity incident) {
    final l10n = AppLocalizations.of(context);
    final isSynced = incident.isSynced;
    final eta = incident.estimatedResponseTime;
    final hasEta = eta != null && eta.isNotEmpty;
    final notes = incident.dispatcherNotes;
    final hasNotes = notes != null && notes.trim().isNotEmpty;
    final titleColor = isSynced ? AppColors.secondary : AppColors.warningLight;
    final dispatchIcon =
        hasEta ? Icons.directions_car_rounded : Icons.support_agent_rounded;

    return NeoTray(
      live: isSynced,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isSynced)
                LiveIndicator(size: 9)
              else
                Icon(Icons.cloud_queue_rounded, size: 17, color: titleColor),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  (isSynced ? l10n.detailLiveTitle : l10n.detailLocalTitle)
                      .toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            isSynced ? l10n.detailLiveMessage : l10n.detailLocalMessage,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: NeoTray.soft,
            ),
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: hasNotes
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (isSynced)
                LiveIndicator.ring(size: 52, child: Icon(dispatchIcon))
              else
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: AppColors.warningLight.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(dispatchIcon, color: AppColors.warningLight, size: 24),
                ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasNotes
                          ? l10n.detailDispatcherNotes
                          : l10n.detailCommandStatus,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: NeoTray.soft,
                      ),
                    ),
                    SizedBox(height: 3),
                    if (hasEta) ...[
                      Text(
                        l10n.detailRespondersDispatched,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          height: 1.35,
                          color: AppColors.secondaryLight,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        eta,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    if (hasNotes) ...[
                      if (hasEta) SizedBox(height: 8),
                      Text(
                        notes,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF1F5F9),
                        ),
                      ),
                    ] else if (!hasEta)
                      Text(
                        l10n.detailAwaitingDispatcher,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── On-Behalf Victim Dossier Card (RA 10173 Compliant) ─────────────────────
  Widget _buildOnBehalfCard(BuildContext context, IncidentEntity incident) {
    final l10n = AppLocalizations.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnFiling = currentUserId != null && currentUserId == incident.reporterId;
    final accent = AppColors.isDarkMode
        ? Color.lerp(AppColors.onBehalf, Colors.white, 0.4)!
        : AppColors.onBehalf;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.onBehalf.withValues(alpha: AppColors.isDarkMode ? 0.22 : 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.people_alt_rounded, color: accent, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.detailOnBehalfBadge,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: accent,
                            letterSpacing: 0.6,
                          ),
                        ),
                        if (isOwnFiling)
                          NeoTag(
                            icon: Icons.verified_rounded,
                            label: l10n.detailYourFiling,
                            color: AppColors.solved,
                          )
                        else
                          NeoTag(
                            icon: Icons.shield_outlined,
                            label: l10n.detailPrivacyBadge,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      isOwnFiling
                          ? l10n.detailOnBehalfOwn
                          : l10n.detailOnBehalfOther,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
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
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: NeoSurface.inset(radius: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.detailAffectedPerson,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isOwnFiling
                      ? (incident.victimName?.isNotEmpty == true
                          ? incident.victimName!
                          : l10n.detailUnspecifiedName)
                      : _maskName(context, incident.victimName),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                if (incident.victimPhone != null &&
                    incident.victimPhone!.trim().isNotEmpty) ...[
                  Divider(color: AppColors.border.withValues(alpha: 0.7), height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.detailVictimContact,
                              style: TextStyle(
                                fontSize: 11.5,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isOwnFiling ? AppColors.primaryText : AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
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
                          tooltip: l10n.detailCallVictim,
                        )
                      else
                        NeoTag(
                          icon: Icons.lock_rounded,
                          label: l10n.detailDispatcherOnly,
                          color: AppColors.textLight,
                        ),
                    ],
                  ),
                ],
                if (!isOwnFiling) ...[
                  SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        size: 15,
                        color: AppColors.isDarkMode
                            ? AppColors.secondaryLight
                            : const Color(0xFF0E7490),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.detailPrivacyNotice,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
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
    final l10n = AppLocalizations.of(context);
    final locationText = BarangaySectorHelper.formatReadableAddress(
      resolvedAddress: incident.resolvedAddress,
      areaSector: incident.areaSector,
      latitude: incident.latitude,
      longitude: incident.longitude,
    );

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.location_on_rounded,
            color: AppColors.danger,
            title: l10n.detailPinnedLocation,
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
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.ink.withValues(alpha: AppColors.isDarkMode ? 0.6 : 0.85),
              borderRadius: BorderRadius.circular(18),
              border: AppColors.isDarkMode
                  ? Border.all(color: AppColors.glassBorder)
                  : null,
            ),
            child: Row(
              children: [
                LiveIndicator(size: 8),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.detailGps("${incident.latitude.toStringAsFixed(6)}, ${incident.longitude.toStringAsFixed(6)}"),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF8FAFC),
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

  // ── Resident Incident Description ───────────────────────────────────────────
  Widget _buildNarrativeCard(BuildContext context, IncidentEntity incident) {
    final l10n = AppLocalizations.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.description_outlined,
            color: AppColors.primary,
            title: l10n.detailNarrative,
          ),
          SizedBox(height: 12),
          Text(
            incident.description.isNotEmpty
                ? incident.description
                : l10n.detailNoDescription,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDark.withValues(alpha: 0.88),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Evidence Card with Tap-to-Zoom & Video Playback ──────────────────────────
  Widget _buildEvidenceCard(BuildContext context, IncidentEntity incident) {
    final l10n = AppLocalizations.of(context);
    final photoUrl = incident.photoUrl;
    final videoUrl = incident.videoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final hasVideo = videoUrl != null && videoUrl.isNotEmpty;

    if (!hasPhoto && !hasVideo) {
      return GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.attachment_rounded,
              color: AppColors.primary,
              title: l10n.detailEvidence,
            ),
            SizedBox(height: 14),
            Container(
              width: double.infinity,
              height: 100,
              decoration: NeoSurface.inset(radius: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.perm_media_outlined,
                      size: 28, color: AppColors.textLight),
                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      l10n.detailNoEvidence,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.perm_media_rounded,
            color: AppColors.primary,
            title: l10n.detailVerifiedEvidence,
          ),
          if (hasPhoto) ...[
            SizedBox(height: 14),
            GestureDetector(
              onTap: () => _openPhotoZoomDialog(context, photoUrl),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _buildImageWidget(photoUrl, height: 210),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    left: 10,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                l10n.detailTapToZoom,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasVideo) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: AppColors.isDarkMode ? 0.22 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.videocam_rounded,
                      color: AppColors.primaryText, size: 20),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.detailVideoEvidence,
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        l10n.detailVideoVerified,
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            NeoButton(
              label: l10n.detailWatchVideo,
              icon: Icons.play_circle_fill_rounded,
              expand: true,
              height: 48,
              onPressed: () {
                InAppEvidencePlayerDialog.show(
                  context,
                  videoUrl: videoUrl,
                  title: l10n.detailEvidenceTitle(
                      LocalizedLabels.category(context, initialIncident.category)),
                );
              },
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
        errorBuilder: (context, error, stackTrace) => _buildImageErrorBlock(context, height),
      );
    }

    final localPath = pathOrUrl.replaceFirst('file://', '');
    return Image.file(
      File(localPath),
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImageErrorBlock(context, height),
    );
  }

  Widget _buildImageErrorBlock(BuildContext context, double? height) {
    return Container(
      width: double.infinity,
      height: height ?? 140,
      decoration: NeoSurface.inset(radius: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 36, color: AppColors.textLight),
          SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).detailPhotoStoredLocally,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  void _openPhotoZoomDialog(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.ink,
        insetPadding: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              child: NeoIconButton(
                icon: Icons.close_rounded,
                tooltip: AppLocalizations.of(ctx).commonClose,
                tone: NeoIconButtonTone.slate,
                size: 44,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card's heading: a tinted icon tile and the title.
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 19,
            color: isDark ? Color.lerp(color, Colors.white, 0.4) : color,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
