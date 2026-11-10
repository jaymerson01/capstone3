import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/my_reports_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/maps_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/instruction_video_page.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/chat/presentation/widgets/floating_chat_bot.dart';
import 'package:community_safety_app/core/presentation/neo/neo_dialog.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/widgets/home_sections.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/features/notifications/data/datasources/notification_service.dart';
import 'package:community_safety_app/core/services/biometric_service.dart';
import 'package:community_safety_app/features/notifications/data/models/notification_model.dart';
import 'package:community_safety_app/features/notifications/presentation/widgets/resident_notifications_sheet.dart';
import 'package:community_safety_app/core/services/fcm_service.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';
import 'package:community_safety_app/core/utils/localized_labels.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _checkFirstTimeBiometricEnrollment();
      await sl<FCMService>().requestNotificationPermissions();
    });
  }

  Future<void> _checkFirstTimeBiometricEnrollment() async {
    final biometricService = sl<BiometricService>();
    final isAvailable = await biometricService.isBiometricAvailable();
    if (!isAvailable) return;

    final hasPrompted = await biometricService.hasPromptedFirstTimeEnrollment();
    if (hasPrompted) return;

    final isAlreadyEnabled = await biometricService.isBiometricLockEnabled();
    if (isAlreadyEnabled) {
      await biometricService.markFirstTimeEnrollmentPrompted();
      return;
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 12, 24, 24 + MediaQuery.of(ctx).padding.bottom),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.isDarkMode
                ? const [Color(0xFF1C2742), Color(0xFF141E36)]
                : const [Color(0xFFF8FAFC), Color(0xFFE9EEF5)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.3),
              blurRadius: 50,
              offset: const Offset(0, -20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            SizedBox(height: 22),
            NeoDialogIcon(
              icon: Icons.fingerprint,
              color: AppColors.primary,
              size: 68,
            ),
            SizedBox(height: 18),
            Text(
              AppLocalizations.of(context).dashboardBiometricTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              AppLocalizations.of(context).dashboardBiometricMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await biometricService.markFirstTimeEnrollmentPrompted();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      AppLocalizations.of(context).dashboardMaybeLater,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: AppColors.primaryGlowShadow,
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final l10n = AppLocalizations.of(context);
                        Navigator.pop(ctx);
                        await biometricService.markFirstTimeEnrollmentPrompted();
                        final didAuth = await biometricService.verifySubmission(
                          reason: l10n.dashboardBiometricReason,
                        );
                        if (didAuth) {
                          await biometricService.setBiometricLockEnabled(true);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.dashboardBiometricEnabled),
                              backgroundColor: AppColors.solved,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        AppLocalizations.of(context).dashboardEnableNow,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case "High":
        return AppColors.danger;
      case "Medium":
        return AppColors.pending;
      case "Low":
        return AppColors.solved;
      default:
        return AppColors.textLight;
    }
  }

  IconData _getIncidentIcon(String category) {
    switch (category) {
      case "Fire Incident":
        return Icons.local_fire_department;
      case "Theft / Robbery":
        return Icons.local_police;
      case "Medical Emergency":
        return Icons.medical_services;
      case "Road Accident":
        return Icons.car_crash;
      case "Suspicious Activity":
        return Icons.visibility;
      case "Flood / Calamity":
        return Icons.flood;
      case "Noise Complaint":
        return Icons.volume_up;
      default:
        return Icons.report_problem;
    }
  }

  String _formatStatus(BuildContext context, String raw) {
    switch (raw.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim()) {
      case 'pending':
        return AppLocalizations.of(context).statusPending;
      case 'inprogress':
        return AppLocalizations.of(context).statusInProgress;
      case 'solved':
      case 'resolved':
        return AppLocalizations.of(context).statusSolved;
      case 'spam':
        return AppLocalizations.of(context).statusSpam;
      case 'archived':
        return AppLocalizations.of(context).statusArchived;
      default:
        return raw;
    }
  }

  Widget _buildSampleReportCard(IncidentEntity incident) {
    final category = incident.category;
    final urgency = incident.urgencyStatus ?? "Medium";
    final urgencyColor = _getUrgencyColor(urgency);
    final location = BarangaySectorHelper.formatReadableAddress(
      resolvedAddress: incident.resolvedAddress,
      areaSector: incident.areaSector,
      latitude: incident.latitude,
      longitude: incident.longitude,
    );
    final time =
        AppLocalizations.of(context).dashboardReportedOn(
            "${incident.timestamp.month}/${incident.timestamp.day}/${incident.timestamp.year}");

    return HomeIncidentRow(
      icon: _getIncidentIcon(category),
      urgencyColor: urgencyColor,
      title: LocalizedLabels.category(context, category),
      status: incident.status,
      statusLabel: _formatStatus(context, incident.status),
      location: location,
      time: time,
      description: incident.description,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MapsPage(focusedIncident: incident),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String userName = AppLocalizations.of(context).commonResident;

    if (authState is Authenticated) {
      final name = authState.user.fullName ?? authState.user.displayName;
      if (name != null && name.trim().isNotEmpty) {
        userName = name.trim().split(RegExp(r'\s+')).first;
      } else if (authState.user.email.isNotEmpty) {
        final emailPart = authState.user.email.split('@').first;
        userName = emailPart.isNotEmpty
            ? emailPart[0].toUpperCase() + emailPart.substring(1)
            : AppLocalizations.of(context).commonResident;
      }
    } else {
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser?.displayName != null && fbUser!.displayName!.trim().isNotEmpty) {
        userName = fbUser.displayName!.trim().split(RegExp(r'\s+')).first;
      } else if (fbUser?.email != null && fbUser!.email!.isNotEmpty) {
        final emailPart = fbUser.email!.split('@').first;
        userName = emailPart.isNotEmpty
            ? emailPart[0].toUpperCase() + emailPart.substring(1)
            : AppLocalizations.of(context).commonResident;
      }
    }

    final padding = MediaQuery.paddingOf(context);
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Stack(
          children: [
            Scaffold(
              // The shell's aurora shows through.
              backgroundColor: Colors.transparent,
              body: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Stack(
                      children: [
                        // ── Landscape behind the welcome header ───────────────
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: 300 + padding.top,
                          child: const HomeHeroLandscape(),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              20, padding.top + 16, 20, padding.bottom + 96),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Welcome header and notifications ─────────────
                              _HomeHeader(userName: userName),
                              SizedBox(height: 24),
                              BlocBuilder<IncidentBloc, IncidentState>(
                                builder: (context, state) {
                                  List<IncidentEntity> incidents = [];
                                  if (state is IncidentLoaded) {
                                    incidents = state.incidents;
                                  }

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // ── Active Municipal Siren / Emergency Broadcast ──
                                      _ActiveEmergencyBanner(),

                                      // ── How to use ResQ (video guide) ──────────────
                                      HomeVideoCard(
                                        title: AppLocalizations.of(context)
                                            .dashboardVideoInstructions,
                                        subtitle: AppLocalizations.of(context)
                                            .dashboardVideoSubtitle,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const InstructionVideoPage(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 18),

                                      // ── My Reports Status (counts) ─────────────────
                                      _QuickStatsRow(incidents: incidents),
                                      SizedBox(height: 18),

                                      // ── Community Reports ──────────────────────────
                                      _buildCommunityReportsSection(state),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const FloatingChatBot(),
          ],
        );
      },
    );
  }

  Widget _buildCommunityReportsSection(IncidentState state) {
    final l10n = AppLocalizations.of(context);
    if (state is IncidentLoading) {
      return HomeCommunityPanel(
        title: l10n.dashboardCommunityIncidents,
        subtitle: l10n.dashboardCommunitySubtitle,
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    } else if (state is IncidentError) {
      return HomeCommunityPanel(
        title: l10n.dashboardCommunityIncidents,
        subtitle: l10n.dashboardCommunitySubtitle,
        children: [
          Center(
            child: Text(l10n.commonError(state.message),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      );
    } else if (state is IncidentLoaded) {
      final recentReports = List<IncidentEntity>.from(state.incidents);
      recentReports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final topReports = recentReports.take(4).toList();

      return HomeCommunityPanel(
        title: l10n.dashboardCommunityIncidents,
        subtitle: l10n.dashboardCommunitySubtitle,
        activeLabel: topReports.isNotEmpty
            ? l10n.dashboardActiveCount(topReports.length)
            : null,
        children: [
          if (topReports.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.solved.withValues(alpha: 0.6),
                        size: 44),
                    SizedBox(height: 10),
                    Text(
                      l10n.dashboardNoActiveIncidents,
                      style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          else
            ...topReports.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              return _AnimatedCardEntrance(
                delay: Duration(milliseconds: 100 * i),
                child: _buildSampleReportCard(r),
              );
            }),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

/// Welcome header with the live unread count on the notifications bell.
class _HomeHeader extends StatelessWidget {
  final String userName;
  const _HomeHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final notificationService = NotificationService();

    return StreamBuilder<List<NotificationModel>>(
      stream: notificationService.streamResidentNotifications(currentUserId),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final unreadCount = notifications.where((n) => !n.isRead).length;

        return HomeHeroHeader(
          welcomeLabel: l10n.dashboardWelcomeBack,
          userName: userName,
          placeLabel: "Barangay Moonwalk • ${l10n.commonResident}",
          unreadCount: unreadCount,
          onNotificationsTap: () {
            ResidentNotificationsSheet.show(context, userId: currentUserId);
          },
        );
      },
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final List<IncidentEntity> incidents;
  const _QuickStatsRow({required this.incidents});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final myIncidents = currentUserId.isNotEmpty
        ? incidents.where((r) => r.reporterId == currentUserId).toList()
        : <IncidentEntity>[];

    final pending = myIncidents.where((r) {
      final s =
          r.status.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim();
      return s == 'pending';
    }).length;
    final inProgress = myIncidents.where((r) {
      final s =
          r.status.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim();
      return s == 'inprogress' || s == 'responding' || s == 'assigned';
    }).length;
    final solved = myIncidents.where((r) {
      final s =
          r.status.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim();
      return s == 'solved' || s == 'resolved';
    }).length;

    final l10n = AppLocalizations.of(context);
    return HomeMyReportsPanel(
      title: l10n.dashboardMyReportsStatus,
      subtitle: l10n.dashboardMyReportsSubtitle,
      viewAllLabel: l10n.dashboardViewAll,
      onOpenMyReports: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyReportsPage()),
      ),
      stats: [
        HomeStat(
          value: pending.toString(),
          label: l10n.dashboardStatPending,
          sublabel: l10n.dashboardStatInQueue,
          color: AppColors.pending,
          icon: Icons.hourglass_empty_rounded,
        ),
        HomeStat(
          value: inProgress.toString(),
          label: l10n.dashboardStatActive,
          sublabel: l10n.dashboardStatResponding,
          color: AppColors.progress,
          icon: Icons.sync_rounded,
          highlight: true,
        ),
        HomeStat(
          value: solved.toString(),
          label: l10n.dashboardStatSolved,
          sublabel: l10n.dashboardStatResolved,
          color: AppColors.solved,
          icon: Icons.check_circle_rounded,
        ),
      ],
    );
  }
}

class _AnimatedCardEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _AnimatedCardEntrance({required this.child, required this.delay});

  @override
  State<_AnimatedCardEntrance> createState() => _AnimatedCardEntranceState();
}

class _AnimatedCardEntranceState extends State<_AnimatedCardEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _ActiveEmergencyBanner extends StatelessWidget {
  const _ActiveEmergencyBanner();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('broadcasts')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;
        final latestDoc = docs.first;
        final data = latestDoc.data() as Map<String, dynamic>;
        final title = data['title'] as String? ?? AppLocalizations.of(context).dashboardAdvisoryFallback;
        final alertType = data['alertType'] as String? ?? AppLocalizations.of(context).dashboardSirenAlertFallback;
        final message = data['message'] as String? ?? "";
        final sector = data['sector'] as String? ?? AppLocalizations.of(context).dashboardAllSectors;

        return HomeSirenCard(
          activeLabel: AppLocalizations.of(context).dashboardActiveSiren,
          alertType: alertType,
          title: title,
          message: message,
          targetLabel:
              AppLocalizations.of(context).dashboardBroadcastTarget(sector),
        );
      },
    );
  }
}
