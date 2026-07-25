import 'package:flutter/material.dart';
import 'constants/admin_colors.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/admin_header.dart';

import 'pages/admin_dashboard_page.dart';
import 'pages/incident_reports_page.dart';
import 'pages/user_management_page.dart';
import 'pages/incident_categories_page.dart';
import 'pages/area_management_page.dart';
import 'pages/admin_audit_logs_page.dart';
import 'pages/profile_settings_page.dart';

class AdminPanelShell extends StatefulWidget {
  const AdminPanelShell({super.key});

  @override
  State<AdminPanelShell> createState() => _AdminPanelShellState();
}

class _AdminPanelShellState extends State<AdminPanelShell> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _pageTitles = [
    "Overview Dashboard",
    "Incident Reports Management",
    "User Management",
    "Incident Categories",
    "Area Management",
    "Admin Audit Logs",
    "Profile Settings",
  ];

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const AdminDashboardPage();
      case 1:
        return const IncidentReportsPage();
      case 2:
        return const UserManagementPage();
      case 3:
        return const IncidentCategoriesPage();
      case 4:
        return const AreaManagementPage();
      case 5:
        return const AdminAuditLogsPage();
      case 6:
        return const ProfileSettingsPage();
      default:
        return const AdminDashboardPage();
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
                      child: const Icon(Icons.logout_rounded,
                          color: Color(0xFFFF3B30), size: 30),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Confirm Logout",
                      style: TextStyle(
                        color: Color(0xFFE8F0FE),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Are you sure you want to log out of the Admin Command Center?",
                      style: TextStyle(
                        color: Color(0xFF7B8DB0),
                        fontSize: 13,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
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
                              child: const Center(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
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
                              child: const Center(
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