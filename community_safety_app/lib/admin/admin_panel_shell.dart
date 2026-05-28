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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text(
            "Are you sure you want to log out of the admin panel?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushReplacementNamed(
                  context,
                  '/admin/login',
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
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