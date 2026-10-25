import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/core/presentation/neo/aurora_background.dart';
import 'package:community_safety_app/core/presentation/neo/neo_bottom_nav.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/dashboard_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/my_reports_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/maps_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/settings_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/report_incident_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, _, _) {
        // The aurora shows through Home and around the floating tab bar.
        return AuroraBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: IndexedStack(
              index: _currentIndex,
              children: const [
                DashboardPage(),
                MyReportsPage(isRootTab: true),
                MapsPage(isRootTab: true),
                SettingsPage(isRootTab: true),
              ],
            ),
            bottomNavigationBar: NeoBottomNav(
              items: [
                NeoNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: l10n.navHome,
                ),
                NeoNavItem(
                  icon: Icons.assignment_outlined,
                  selectedIcon: Icons.assignment_rounded,
                  label: l10n.navReports,
                ),
                NeoNavItem(
                  icon: Icons.map_outlined,
                  selectedIcon: Icons.map_rounded,
                  label: l10n.navMap,
                ),
                NeoNavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: l10n.navMore,
                ),
              ],
              currentIndex: _currentIndex,
              onTap: (index) {
                HapticFeedback.selectionClick();
                setTab(index);
              },
              reportLabel: l10n.navReport,
              onReport: _openReportIncidentFlow,
            ),
          ),
        );
      },
    );
  }
}
