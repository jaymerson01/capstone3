import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/dashboard_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/report_incident_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/my_reports_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/maps_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/settings_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String hoveredItem = "";

  @override
  Widget build(BuildContext context) {
    // Determine active route name to show proper selected state
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF060D1A), Color(0xFF0A1628)],
          ),
          border: Border(
            right: BorderSide(color: Color(0xFF1E2D4A), width: 1),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header banner inside sidebar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1.5,
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 38,
                        width: 38,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "RESQ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            "Citizen Portal",
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF1E2D4A), height: 1),
              const SizedBox(height: 20),

              menuItem(context, Icons.home_outlined, "User Dashboard", currentRoute == null || currentRoute == '/'),
              menuItem(context, Icons.warning_amber_rounded, "Report Incident", false),
              menuItem(context, Icons.list_alt_rounded, "My Reports", false),
              menuItem(context, Icons.map_outlined, "Maps", false),
              menuItem(context, Icons.settings_outlined, "Settings", false),

              const Spacer(),
              const Divider(color: Color(0xFF1E2D4A), height: 1),
              const SizedBox(height: 16),
              menuItem(context, Icons.logout_rounded, "Logout", false),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuItem(BuildContext context, IconData icon, String title, bool isSelected) {
    final bool isHovered = hoveredItem == title;
    final bool isLogout = title == "Logout";

    // Build the visual state colors
    Color tileBgColor = Colors.transparent;
    Color iconColor = Colors.white70;
    Color textColor = Colors.white70;
    Border border = Border.all(color: Colors.transparent);

    if (isLogout) {
      tileBgColor = isHovered
          ? AppColors.danger.withValues(alpha: 0.25)
          : AppColors.danger.withValues(alpha: 0.12);
      iconColor = AppColors.danger;
      textColor = AppColors.danger;
      border = Border.all(
        color: isHovered
            ? AppColors.danger.withValues(alpha: 0.5)
            : AppColors.danger.withValues(alpha: 0.25),
      );
    } else {
      if (isSelected) {
        tileBgColor = AppColors.primary.withValues(alpha: 0.15);
        iconColor = AppColors.primary;
        textColor = Colors.white;
        border = Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        );
      } else if (isHovered) {
        tileBgColor = Colors.white.withValues(alpha: 0.06);
        iconColor = Colors.white;
        textColor = Colors.white;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            hoveredItem = title;
          });
        },
        onExit: (_) {
          setState(() {
            hoveredItem = "";
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: tileBgColor,
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: (isSelected || isHovered) ? FontWeight.bold : FontWeight.w500,
                  color: textColor,
                ),
              ),
              hoverColor: Colors.transparent,
              onTap: () {
                Navigator.pop(context); // Close Drawer

                if (title == "User Dashboard") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardPage(),
                    ),
                  );
                } else if (title == "Report Incident") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: sl<IncidentBloc>(),
                        child: const ReportIncidentPage(),
                      ),
                    ),
                  );
                } else if (title == "My Reports") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: sl<IncidentBloc>(),
                        child: const MyReportsPage(),
                      ),
                    ),
                  );
                } else if (title == "Maps") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapsPage()),
                  );
                } else if (title == "Settings") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                } else if (title == "Logout") {
                  context.read<AuthBloc>().add(const LogoutRequested());

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomePage()),
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
