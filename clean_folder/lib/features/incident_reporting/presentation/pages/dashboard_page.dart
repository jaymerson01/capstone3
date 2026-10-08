import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/my_reports_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/maps_page.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/chat/presentation/widgets/floating_chat_bot.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/features/notifications/data/datasources/notification_service.dart';
import 'package:community_safety_app/core/services/biometric_service.dart';
import 'package:community_safety_app/features/notifications/data/models/notification_model.dart';
import 'package:community_safety_app/features/notifications/presentation/widgets/resident_notifications_sheet.dart';
import 'package:community_safety_app/core/services/fcm_service.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';

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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1627),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: const Color(0xFF1E2D4A), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2A3F60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0x3300E5FF), Color(0x0500E5FF)],
                ),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.fingerprint,
                color: Color(0xFF00E5FF),
                size: 34,
              ),
            ),
            SizedBox(height: 18),
            Text(
              "Enable Quick Biometric Access",
              style: TextStyle(
                color: Color(0xFFE8F0FE),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Protect your ResQ account and instantly verify emergency incident reports using your Fingerprint or Face ID.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7B8DB0),
                fontSize: 13,
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
                    ),
                    child: Text(
                      "Maybe Later",
                      style: TextStyle(
                        color: Color(0xFF7B8DB0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A84FF), Color(0xFF00E5FF)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0A84FF).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await biometricService.markFirstTimeEnrollmentPrompted();
                        final didAuth = await biometricService.verifySubmission(
                          reason:
                              "Scan fingerprint or face to enable Biometric Quick Access",
                        );
                        if (didAuth) {
                          await biometricService.setBiometricLockEnabled(true);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Biometric verification enabled for ResQ!"),
                              backgroundColor: Color(0xFF34C759),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "Enable Now",
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
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

  Widget _buildSampleReportCard(IncidentEntity incident) {
    final category = incident.category;
    final urgency = incident.urgencyStatus ?? "Medium";
    final urgencyColor = _getUrgencyColor(urgency);
    final statusClr = AppColors.statusColor(incident.status);
    final location = BarangaySectorHelper.formatReadableAddress(
      resolvedAddress: incident.resolvedAddress,
      areaSector: incident.areaSector,
      latitude: incident.latitude,
      longitude: incident.longitude,
    );
    final time =
        "Reported ${incident.timestamp.month}/${incident.timestamp.day}/${incident.timestamp.year}";

    return Custom3dCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      glowColor: urgencyColor,
      enableHoverLift: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MapsPage(focusedIncident: incident),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: urgencyColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: urgencyColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(_getIncidentIcon(category),
                color: urgencyColor, size: 24),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: urgencyColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.textLight),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 13, color: AppColors.textLight),
                    SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                          color: AppColors.textLight, fontSize: 11),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  incident.description,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusChip(status: incident.status, color: statusClr),
                    Icon(Icons.chevron_right_rounded,
                        size: 20, color: AppColors.textMuted),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String userName = "Resident";

    if (authState is Authenticated) {
      final name = authState.user.fullName ?? authState.user.displayName;
      if (name != null && name.trim().isNotEmpty) {
        userName = name.trim().split(RegExp(r'\s+')).first;
      } else if (authState.user.email.isNotEmpty) {
        final emailPart = authState.user.email.split('@').first;
        userName = emailPart.isNotEmpty
            ? emailPart[0].toUpperCase() + emailPart.substring(1)
            : "Resident";
      }
    } else {
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser?.displayName != null && fbUser!.displayName!.trim().isNotEmpty) {
        userName = fbUser.displayName!.trim().split(RegExp(r'\s+')).first;
      } else if (fbUser?.email != null && fbUser!.email!.isNotEmpty) {
        final emailPart = fbUser.email!.split('@').first;
        userName = emailPart.isNotEmpty
            ? emailPart[0].toUpperCase() + emailPart.substring(1)
            : "Resident";
      }
    }

    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.background,
              appBar: _PremiumAppBar(userName: userName),
              body: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: BlocBuilder<IncidentBloc, IncidentState>(
                      builder: (context, state) {
                        List<IncidentEntity> incidents = [];
                        if (state is IncidentLoaded) {
                          incidents = state.incidents;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Welcome Hero Card ──────────────────────────────────────
                            _WelcomeHeroCard(userName: userName),
                            SizedBox(height: 18),

                            // ── Active Municipal Siren / Emergency Broadcast ──────────
                            _ActiveEmergencyBanner(),

                            // ── Barangay Situation Overview (Community-wide) ──────────
                            _buildBarangaySituationHeader(context),
                            SizedBox(height: 10),
                            _QuickStatsRow(incidents: incidents),
                            SizedBox(height: 20),

                            // ── Video / Info Banner ────────────────────────────────────
                            _InfoBanner(),
                            SizedBox(height: 24),

                            // ── Community Reports ──────────────────────────────────────
                            _buildCommunityReportsSection(state),
                            SizedBox(height: 30),
                          ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
          const FloatingChatBot(),
        ],
      );
      }
    );
  }

  Widget _buildBarangaySituationHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 15,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "MY REPORTS STATUS",
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyReportsPage()),
              ),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 9, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          "Personal incident filings • Real-time response tracking",
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCommunityReportsSection(IncidentState state) {
    if (state is IncidentLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    } else if (state is IncidentError) {
      return Center(
        child: Text("Error: ${state.message}",
            style: TextStyle(color: AppColors.danger)),
      );
    } else if (state is IncidentLoaded) {
      final recentReports = List<IncidentEntity>.from(state.incidents);
      recentReports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final topReports = recentReports.take(4).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "Community Incidents",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (topReports.isNotEmpty)
                Text(
                  "${topReports.length} Active",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            "Recent reports from nearby compounds and streets",
            style: TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16),
          if (topReports.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.solved.withValues(alpha: 0.5),
                        size: 48),
                    SizedBox(height: 12),
                    Text(
                      "No active incidents",
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

class _PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  const _PremiumAppBar({required this.userName});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Container(
          height: 64 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: isDark ? 12 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.primary,
                    child: Icon(Icons.shield,
                        color: AppColors.textDark, size: 16),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.cyanGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                "RESQ",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
            const Spacer(),
            Builder(
              builder: (context) {
                final currentUserId =
                    FirebaseAuth.instance.currentUser?.uid ?? '';
                final notificationService = NotificationService();

                return StreamBuilder<List<NotificationModel>>(
                  stream: notificationService
                      .streamResidentNotifications(currentUserId),
                  builder: (context, snapshot) {
                    final notifications = snapshot.data ?? [];
                    final unreadCount =
                        notifications.where((n) => !n.isRead).length;

                    return InkWell(
                      onTap: () {
                        ResidentNotificationsSheet.show(context,
                            userId: currentUserId);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: unreadCount > 0
                                  ? const Color(0xFF162544)
                                  : AppColors.primary.withValues(alpha: 0.12),
                              border: Border.all(
                                color: unreadCount > 0
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.3),
                                width: unreadCount > 0 ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                      alpha: unreadCount > 0 ? 0.35 : 0.15),
                                  blurRadius: unreadCount > 0 ? 12 : 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                unreadCount > 0
                                    ? Icons.notifications_active_rounded
                                    : Icons.notifications_none_rounded,
                                color: unreadCount > 0
                                    ? AppColors.primary
                                    : AppColors.textLight,
                                size: 20,
                              ),
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                constraints: const BoxConstraints(
                                    minWidth: 18, minHeight: 18),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF3B30),
                                      Color(0xFFD32F2F)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFF0D1627),
                                      width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF3B30)
                                          .withValues(alpha: 0.6),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    unreadCount > 9 ? '9+' : '$unreadCount',
                                    style: TextStyle(color: AppColors.textDark,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}

class _WelcomeHeroCard extends StatelessWidget {
  final String userName;
  const _WelcomeHeroCard({required this.userName});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF0A1628), const Color(0xFF0D1F3C)]
                  : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
                blurRadius: isDark ? 12 : 8,
                offset: const Offset(0, 3),
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
                  "Welcome back,",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Barangay Moonwalk",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.textLight.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Resident",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Icon(Icons.verified_user_outlined,
                color: AppColors.primary, size: 28),
          ),
        ],
      ),
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

    return Row(
      children: [
        _MiniStatCard(
          label: "Pending",
          sublabel: "In Queue",
          value: pending.toString(),
          color: AppColors.pending,
          icon: Icons.hourglass_empty_rounded,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyReportsPage()),
          ),
        ),
        SizedBox(width: 10),
        _MiniStatCard(
          label: "Active",
          sublabel: "Responding",
          value: inProgress.toString(),
          color: AppColors.progress,
          icon: Icons.sync_rounded,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyReportsPage()),
          ),
        ),
        SizedBox(width: 10),
        _MiniStatCard(
          label: "Solved",
          sublabel: "Resolved",
          value: solved.toString(),
          color: AppColors.solved,
          icon: Icons.check_circle_rounded,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyReportsPage()),
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String value;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _MiniStatCard({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withValues(alpha: 0.15),
          highlightColor: color.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  sublabel,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
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

class _InfoBanner extends StatefulWidget {
  const _InfoBanner();
  @override
  State<_InfoBanner> createState() => _InfoBannerState();
}

class _InfoBannerState extends State<_InfoBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1628), Color(0xFF0D2040)],
        ),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(
                                  alpha: 0.5 * _pulseController.value),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(Icons.play_arrow,
                            color: AppColors.textDark, size: 26),
                      );
                    },
                  ),
                  SizedBox(height: 14),
                  Text(
                    "Video Instructions",
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "How to report safety issues in Moonwalk",
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  String _formatStatus(String raw) {
    switch (raw.toLowerCase().replaceAll('_', '').replaceAll(' ', '').trim()) {
      case 'pending':
        return 'Pending';
      case 'inprogress':
        return 'In Progress';
      case 'solved':
      case 'resolved':
        return 'Solved';
      case 'spam':
        return 'Spam';
      case 'archived':
        return 'Archived';
      default:
        return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayStatus = _formatStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
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
        final title = data['title'] as String? ?? "EMERGENCY ADVISORY";
        final alertType = data['alertType'] as String? ?? "Siren Alert";
        final message = data['message'] as String? ?? "";
        final sector = data['sector'] as String? ?? "All Sectors";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A0A10), Color(0xFF160A14)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFF3B30), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF3B30).withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.campaign_rounded,
                        color: Color(0xFFFF3B30), size: 20),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              alertType.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFFF9500),
                                fontWeight: FontWeight.w900,
                                fontSize: 10.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "ACTIVE SIREN",
                                style: TextStyle(
                                  color: Color(0xFFFF3B30),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          title,
                          style: TextStyle(color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (message.isNotEmpty) ...[
                SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFE8F0FE),
                    fontSize: 12,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.place_outlined,
                      size: 13, color: Color(0xFF7B8DB0)),
                  SizedBox(width: 4),
                  Text(
                    "Target: $sector",
                    style: const TextStyle(
                      color: Color(0xFF7B8DB0),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
