import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../pages/dashboard.dart';
import '../pages/report_incident.dart';
import '../pages/my_reports.dart';
import '../pages/maps.dart';
import '../pages/settings.dart';
import '../pages/welcome_page.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String hoveredItem = "";

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.darkGreen,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            menuItem(context, Icons.home, "User Dashboard"),
            menuItem(context, Icons.warning_amber, "Report Incident"),
            menuItem(context, Icons.list_alt, "My Reports"),
            menuItem(context, Icons.map, "Maps"),
            menuItem(context, Icons.settings, "Settings"),

            const Spacer(),

            menuItem(context, Icons.logout, "Logout"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget menuItem(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    bool isHovered = hoveredItem == title;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
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
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isHovered
                ? Colors.green.shade200
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    )
                  ]
                : [],
          ),
          child: ListTile(
            leading: Icon(icon, color: Colors.black),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            hoverColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);

              if (title == "User Dashboard") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardPage(),
                  ),
                );
              }

              if (title == "Report Incident") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ReportIncidentPage(),
                  ),
                );
              }

              if (title == "My Reports") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MyReportsPage(),
                  ),
                );
              }

              if (title == "Maps") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapsPage(),
                  ),
                );
              }

              if (title == "Settings") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SettingsPage(),
                  ),
                );
              }

              if (title == "Logout") {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomePage(),
                  ),
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