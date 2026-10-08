import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/dashboard_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/my_reports_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/maps_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/settings_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/report_incident_page.dart';

class ResidentNavShell extends StatefulWidget {
  final int initialIndex;

  const ResidentNavShell({
    super.key,
    this.initialIndex = 0,
  });

  /// Allows any child widget or drawer to switch tabs programmatically
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_ResidentNavShellState>();
    if (state != null) {
      state.setTab(index);
    }
  }

  @override
  State<ResidentNavShell> createState() => _ResidentNavShellState();
}

class _ResidentNavShellState extends State<ResidentNavShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setTab(int index) {
    if (index >= 0 && index < 4 && _currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _openReportIncidentFlow() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: sl<IncidentBloc>(),
          child: const ReportIncidentPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              DashboardPage(),
              MyReportsPage(isRootTab: true),
              MapsPage(isRootTab: true),
              SettingsPage(isRootTab: true),
            ],
          ),
          bottomNavigationBar: _ResidentBottomBar(
            currentIndex: _currentIndex,
            isDark: isDark,
            onTabSelected: (index) {
              HapticFeedback.selectionClick();
              setTab(index);
            },
            onCenterAction: _openReportIncidentFlow,
          ),
        );
      },
    );
  }
}

class _ResidentBottomBar extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onCenterAction;

  const _ResidentBottomBar({
    required this.currentIndex,
    required this.isDark,
    required this.onTabSelected,
    required this.onCenterAction,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF091424) : Colors.white;
    final borderColor = isDark ? const Color(0xFF162A45) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // 0: Home
              Expanded(
                child: _NavBarItem(
                  icon: Icons.home_rounded,
                  unselectedIcon: Icons.home_outlined,
                  label: "Home",
                  isSelected: currentIndex == 0,
                  onTap: () => onTabSelected(0),
                ),
              ),

              // 1: Reports
              Expanded(
                child: _NavBarItem(
                  icon: Icons.assignment_rounded,
                  unselectedIcon: Icons.assignment_outlined,
                  label: "Reports",
                  isSelected: currentIndex == 1,
                  onTap: () => onTabSelected(1),
                ),
              ),

              // Center: Elevated Emergency Report Action
              Expanded(
                child: GestureDetector(
                  onTap: onCenterAction,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -10),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF3B30), Color(0xFFFF6A3D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF3B30).withValues(alpha: 0.45),
                                blurRadius: 14,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -6),
                        child: const Text(
                          "REPORT",
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                            color: Color(0xFFFF3B30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2: Map
              Expanded(
                child: _NavBarItem(
                  icon: Icons.map_rounded,
                  unselectedIcon: Icons.map_outlined,
                  label: "Map",
                  isSelected: currentIndex == 2,
                  onTap: () => onTabSelected(2),
                ),
              ),

              // 3: More / Settings
              Expanded(
                child: _NavBarItem(
                  icon: Icons.settings_rounded,
                  unselectedIcon: Icons.settings_outlined,
                  label: "More",
                  isSelected: currentIndex == 3,
                  onTap: () => onTabSelected(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData unselectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.unselectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    final inactiveColor = AppColors.textLight.withValues(alpha: 0.7);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? icon : unselectedIcon,
                color: isSelected ? activeColor : inactiveColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
