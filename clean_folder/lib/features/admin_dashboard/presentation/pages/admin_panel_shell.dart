import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_sidebar.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_header.dart';

import 'package:community_safety_app/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/admin_dispatch_map_page.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/incident_reports_page.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/reports_analytics_page.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/user_management_page.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/admin_audit_logs_page.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/profile_settings_page.dart';
import 'package:community_safety_app/features/notifications/data/datasources/notification_service.dart';
import 'package:community_safety_app/features/notifications/data/models/notification_model.dart';
import 'package:community_safety_app/core/services/station_audio_service.dart';

class AdminPanelShell extends StatefulWidget {
  const AdminPanelShell({super.key});

  @override
  State<AdminPanelShell> createState() => _AdminPanelShellState();
}

class _AdminPanelShellState extends State<AdminPanelShell> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<List<NotificationModel>>? _adminNotifSubscription;
  final Set<String> _seenAdminNotifIds = {};
  bool _isInitialSnapshot = true;

  @override
  void initState() {
    super.initState();
    _adminNotifSubscription = NotificationService()
        .streamAdminNotifications()
        .listen((notifications) {
      if (_isInitialSnapshot) {
        for (final n in notifications) {
          _seenAdminNotifIds.add(n.id);
        }
        _isInitialSnapshot = false;
        return;
      }

      for (final n in notifications) {
        if (!_seenAdminNotifIds.contains(n.id)) {
          _seenAdminNotifIds.add(n.id);
          if (!n.isRead) {
            // Trigger emergency station audio chime
            StationAudioService.playAlertSound();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF0D1627),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
                  ),
                  duration: const Duration(seconds: 8),
                  content: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emergency_rounded,
                          color: Color(0xFFFF3B30),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              n.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              n.message,
                              style: const TextStyle(
                                color: Color(0xFF7B8DB0),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          setState(() => _selectedIndex = 2);
                        },
                        child: Text(
                          "VIEW",
                          style: TextStyle(
                            color: Color(0xFF0A84FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _adminNotifSubscription?.cancel();
    super.dispose();
  }


  final List<String> _pageTitles = [
    "Overview Dashboard",
    "Tactical Dispatch Map",
    "Incident Reports Management",
    "Reports & Analytics Hub",
    "Citizen Directory & Moderation",
    "Admin Audit Logs",
    "Profile Settings",
  ];

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return AdminDashboardPage(
          onViewAllReports: () => setState(() => _selectedIndex = 2),
        );
      case 1:
        return const AdminDispatchMapPage();
      case 2:
        return const IncidentReportsPage();
      case 3:
        return const ReportsAnalyticsPage();
      case 4:
        return const UserManagementPage();
      case 5:
        return const AdminAuditLogsPage();
      case 6:
        return const ProfileSettingsPage();
      default:
        return AdminDashboardPage(
          onViewAllReports: () => setState(() => _selectedIndex = 2),
        );
    }
  }

  void _handleLogout() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: Dialog(
              backgroundColor: const Color(0xFF0D1627),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(Icons.logout_rounded,
                          color: Color(0xFFFF3B30), size: 30),
                    ),
                    SizedBox(height: 18),
                    Text(
                      "Confirm Logout",
                      style: TextStyle(
                        color: Color(0xFFE8F0FE),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Are you sure you want to log out of the Admin Command Center?",
                      style: TextStyle(
                        color: Color(0xFF7B8DB0),
                        fontSize: 13,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Color(0xFF7B8DB0),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              context.read<AuthBloc>().add(const LogoutRequested());
                              Navigator.pushReplacementNamed(
                                  context, '/admin/login');
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFFFF3B30)
                                        .withValues(alpha: 0.4)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF3B30)
                                        .withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Color(0xFFFF3B30),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
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
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AdminColors.background,
      drawer: isMobile
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });

                  _scaffoldKey.currentState?.closeDrawer();
                },
                isCollapsed: false,
                onLogout: _handleLogout,
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              isCollapsed: _isSidebarCollapsed,
              onLogout: _handleLogout,
            ),

          Expanded(
            child: Column(
              children: [
                AdminHeader(
                  title: _pageTitles[_selectedIndex],
                  isMobile: isMobile,
                  onNavigate: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  onLogout: _handleLogout,
                  onMenuPressed: () {
                    if (isMobile) {
                      _scaffoldKey.currentState?.openDrawer();
                    } else {
                      setState(() {
                        _isSidebarCollapsed = !_isSidebarCollapsed;
                      });
                    }
                  },
                ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_selectedIndex),
                      child: _getSelectedPage(),
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
}
