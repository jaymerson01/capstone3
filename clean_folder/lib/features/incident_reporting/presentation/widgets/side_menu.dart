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
import 'package:community_safety_app/l10n/app_localizations.dart';

/// Side menu entries. Navigation keys off these, not the (translated) labels.
enum _MenuDestination { dashboard, reportIncident, myReports, maps, settings, logout }

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  _MenuDestination? hoveredItem;

  @override
  Widget build(BuildContext context) {
    // Determine active route name to show proper selected state
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Drawer(
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [Color(0xFF1C2742), Color(0xFF141E36)]
                    : const [Color(0xFFF8FAFC), Color(0xFFE9EEF5)],
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppColors.raisedShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 48,
                              width: 48,
                              fit: BoxFit.cover,
                            ),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                l10n.menuCitizenPortal,
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: AppColors.surfaceLight, height: 1),
                  const SizedBox(height: 20),

                  menuItem(context, Icons.home_outlined, l10n.menuDashboard, _MenuDestination.dashboard, currentRoute == null || currentRoute == '/', isDark),
                  menuItem(context, Icons.warning_amber_rounded, l10n.menuReportIncident, _MenuDestination.reportIncident, false, isDark),
                  menuItem(context, Icons.list_alt_rounded, l10n.menuMyReports, _MenuDestination.myReports, false, isDark),
                  menuItem(context, Icons.map_outlined, l10n.menuMaps, _MenuDestination.maps, false, isDark),
                  menuItem(context, Icons.settings_outlined, l10n.menuSettings, _MenuDestination.settings, false, isDark),

                  const Spacer(),
                  Divider(color: AppColors.surfaceLight, height: 1),
                  const SizedBox(height: 16),
                  menuItem(context, Icons.logout_rounded, l10n.menuLogout, _MenuDestination.logout, false, isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget menuItem(BuildContext context, IconData icon, String title, _MenuDestination destination, bool isSelected, bool isDark) {
    final bool isHovered = hoveredItem == destination;
    final bool isLogout = destination == _MenuDestination.logout;

    // Build the visual state colors
    Color tileBgColor = Colors.transparent;
    Color iconColor = AppColors.textLight;
    Color textColor = AppColors.textDark;
    Border border = Border.all(color: Colors.transparent);

    if (isLogout) {
      tileBgColor = AppColors.danger.withValues(alpha: isHovered ? 0.18 : 0.1);
      iconColor = AppColors.danger;
      textColor = AppColors.danger;
      border = Border.all(
        color: AppColors.danger.withValues(alpha: isHovered ? 0.4 : 0.2),
      );
    } else {
      if (isSelected) {
        tileBgColor = isDark
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.lightGreen;
        iconColor = AppColors.primaryText;
        textColor = AppColors.primaryText;
        border = Border.all(color: AppColors.primary.withValues(alpha: 0.3));
      } else if (isHovered) {
        tileBgColor = isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.7);
        iconColor = AppColors.textDark;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            hoveredItem = destination;
          });
        },
        onExit: (_) {
          setState(() {
            hoveredItem = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: tileBgColor,
            borderRadius: BorderRadius.circular(16),
            border: border,
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: (isSelected || isHovered) ? FontWeight.w800 : FontWeight.w600,
                  color: textColor,
                ),
              ),
              hoverColor: Colors.transparent,
              onTap: () {
                if (destination == _MenuDestination.dashboard) {
                  ResidentNavShell.switchTab(context, 0);
                  Navigator.pop(context);
                } else if (destination == _MenuDestination.reportIncident) {
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
                } else if (destination == _MenuDestination.myReports) {
                  ResidentNavShell.switchTab(context, 1);
                  Navigator.pop(context);
                } else if (destination == _MenuDestination.maps) {
                  ResidentNavShell.switchTab(context, 2);
                  Navigator.pop(context);
                } else if (destination == _MenuDestination.settings) {
                  ResidentNavShell.switchTab(context, 3);
                  Navigator.pop(context);
                } else if (destination == _MenuDestination.logout) {
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
