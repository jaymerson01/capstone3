import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/report_incident_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/resident_nav_shell.dart';

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

    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Drawer(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF060D1A), const Color(0xFF0A1628)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
              ),
              border: Border(
                right: BorderSide(color: AppColors.border, width: 1),
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
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.18)
                                  : AppColors.primary.withValues(alpha: 0.2),
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
                            children: [
                              Text(
                                "RESQ",
                                style: TextStyle(
                                  color: AppColors.textDark,
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
                  Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 20),

                  menuItem(context, Icons.home_outlined, "User Dashboard", currentRoute == null || currentRoute == '/', isDark),
                  menuItem(context, Icons.warning_amber_rounded, "Report Incident", false, isDark),
                  menuItem(context, Icons.list_alt_rounded, "My Reports", false, isDark),
                  menuItem(context, Icons.map_outlined, "Maps", false, isDark),
                  menuItem(context, Icons.settings_outlined, "Settings", false, isDark),

                  const Spacer(),
                  Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),
                  menuItem(context, Icons.logout_rounded, "Logout", false, isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget menuItem(BuildContext context, IconData icon, String title, bool isSelected, bool isDark) {
    final bool isHovered = hoveredItem == title;
    final bool isLogout = title == "Logout";

    // Build the visual state colors
    Color tileBgColor = Colors.transparent;
    Color iconColor = isDark ? Colors.white70 : AppColors.textLight;
    Color textColor = isDark ? Colors.white70 : AppColors.textDark;
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
        tileBgColor = AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1);
        iconColor = AppColors.primary;
        textColor = AppColors.primary;
        border = Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        );
      } else if (isHovered) {
        tileBgColor = isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04);
        iconColor = isDark ? Colors.white : AppColors.textDark;
        textColor = isDark ? Colors.white : AppColors.textDark;
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
                if (title == "User Dashboard") {
                  ResidentNavShell.switchTab(context, 0);
                  Navigator.pop(context);
                } else if (title == "Report Incident") {
                  Navigator.pop(context);
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
                  ResidentNavShell.switchTab(context, 1);
                  Navigator.pop(context);
                } else if (title == "Maps") {
                  ResidentNavShell.switchTab(context, 2);
                  Navigator.pop(context);
                } else if (title == "Settings") {
                  ResidentNavShell.switchTab(context, 3);
                  Navigator.pop(context);
                } else if (title == "Logout") {
                  Navigator.pop(context);
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
