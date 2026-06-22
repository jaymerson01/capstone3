import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../pages/resident_dashboard_page.dart';
import '../pages/report_incident_page.dart';
import '../pages/incident_overview_page.dart';
import '../pages/maps_page.dart';
import '../pages/settings_page.dart';
import '../../../auth/presentation/pages/welcome_page.dart';

class SideMenu extends StatefulWidget {
  final String currentPage;
  const SideMenu({super.key, this.currentPage = ""});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String hoveredItem = "";

  @override
  Widget build(BuildContext context) {
    // Determine active route name to show proper selected state if mapped
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: AppColors.darkGreen,
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
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 40,
                      width: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.security,
                        size: 24,
                        color: Colors.white,
                      ),
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
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          "Citizen Portal",
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 20),

            menuItem(
              context,
              Icons.home_outlined,
              "User Dashboard",
              widget.currentPage == "User Dashboard" ||
                  currentRoute == '/dashboard',
            ),
            menuItem(
              context,
              Icons.warning_amber_rounded,
              "Report Incident",
              widget.currentPage == "Report Incident",
            ),
            menuItem(
              context,
              Icons.list_alt_rounded,
              "My Reports",
              widget.currentPage == "My Reports",
            ),
            menuItem(
              context,
              Icons.map_outlined,
              "Maps",
              widget.currentPage == "Maps",
            ),
            menuItem(
              context,
              Icons.settings_outlined,
              "Settings",
              widget.currentPage == "Settings",
            ),

            const Spacer(),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 16),
            menuItem(context, Icons.logout_rounded, "Logout", false),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget menuItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isSelected,
  ) {
    final bool isHovered = hoveredItem == title;
    final bool isLogout = title == "Logout";

    // Build visual state colors
    Color tileBgColor = Colors.transparent;
    Color iconColor = Colors.white70;
    Color textColor = Colors.white70;

    if (isLogout) {
      tileBgColor = isHovered
          ? AppColors.danger.withValues(alpha: 0.3)
          : AppColors.danger.withValues(alpha: 0.18);
      iconColor = Colors.red.shade200;
      textColor = Colors.red.shade100;
    } else {
      if (isSelected) {
        tileBgColor = Colors.white.withValues(alpha: 0.15);
        iconColor = Colors.white;
        textColor = Colors.white;
      } else if (isHovered) {
        tileBgColor = Colors.white.withValues(alpha: 0.08);
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
          ),
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            leading: Icon(icon, color: iconColor, size: 22),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: (isSelected || isHovered)
                    ? FontWeight.bold
                    : FontWeight.w500,
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
                    builder: (context) => const ResidentDashboardPage(),
                  ),
                );
              } else if (title == "Report Incident") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportIncidentPage(),
                  ),
                );
              } else if (title == "My Reports") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IncidentOverviewPage(),
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
    );
  }
}
