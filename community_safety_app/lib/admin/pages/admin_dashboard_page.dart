import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import '../services/admin_data_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/custom_line_chart.dart';
import '../widgets/custom_pie_chart.dart';
import '../constants/admin_colors.dart';
import '../../widgets/custom_3d_card.dart';
import '../../theme/app_color.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = AdminDataService();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1100;
    final bool isTablet = screenWidth >= 700 && screenWidth < 1100;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: ListenableBuilder(
        listenable: dataService,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome Header ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A1628), Color(0xFF0D2040)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back, Admin!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Monitor community safety alerts and dispatch statuses in Moonwalk.",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textLight,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Live status pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.solved.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      AppColors.solved.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.solved,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.solved
                                            .withValues(alpha: 0.6),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 7),
                                const Text(
                                  "Command Center Online",
                                  style: TextStyle(
                                    color: AppColors.solved,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Date badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 18, color: AppColors.primary),
                          const SizedBox(height: 6),
                          Text(
                            "${DateTime.now().day}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            _monthName(DateTime.now().month),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Stat Cards ──────────────────────────────────────────────
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    title: "Incident Reports",
                    value: dataService.totalIncidents.toString(),
                    icon: Icons.warning_amber_rounded,
                    backgroundColor: const Color(0xFFFF3B30),
                  ),
                  StatCard(
                    title: "Total Areas",
                    value: dataService.totalAreas.toString(),
                    icon: Icons.map_outlined,
                    backgroundColor: const Color(0xFF0A84FF),
                  ),
                  StatCard(
                    title: "Solved Cases",
                    value: dataService.solvedCases.toString(),
                    icon: Icons.check_circle_outline,
                    backgroundColor: const Color(0xFF30D158),
                  ),
                  StatCard(
                    title: "Registered Users",
                    value: dataService.registeredUsers.toString(),
                    icon: Icons.people_alt_outlined,
                    backgroundColor: const Color(0xFF6E40C9),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Charts ──────────────────────────────────────────────────
              if (isDesktop)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: CustomLineChart()),
                    SizedBox(width: 20),
                    Expanded(flex: 4, child: CustomPieChart()),
                  ],
                )
              else
                const Column(
                  children: [
                    CustomLineChart(),
                    SizedBox(height: 20),
                    CustomPieChart(),
                  ],
                ),

              const SizedBox(height: 28),

              // ── Recent Incidents Table ──────────────────────────────────
              Custom3dCard(
                padding: const EdgeInsets.all(22),
                borderRadius: 22,
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.bolt_outlined,
                                  color: AppColors.primary, size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Recent Urgent Incidents",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 10),
                                    Text(
                                        "Navigate to 'Incident Reports' from sidebar."),
                                  ],
                                ),
                                backgroundColor: AppColors.surface,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                      color: AppColors.border),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward,
                              size: 14, color: AppColors.primary),
                          label: const Text(
                            "View All",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: AppColors.border),
                    const SizedBox(height: 12),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dataService.reports.take(4).length,
                      separatorBuilder: (context, index) => Container(
                        height: 1,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      itemBuilder: (context, index) {
                        final report = dataService.reports[index];
                        final statusClr =
                            AppColors.statusColor(report.statusLabel);

                        return _IncidentRow(
                          report: report,
                          statusColor: statusClr,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

class _IncidentRow extends StatefulWidget {
  final dynamic report;
  final Color statusColor;

  const _IncidentRow({required this.report, required this.statusColor});

  @override
  State<_IncidentRow> createState() => _IncidentRowState();
}

class _IncidentRowState extends State<_IncidentRow> {
  bool _hovered = false;

  IconData _getIcon(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.solved:
        return Icons.check_circle_outline;
      case IncidentStatus.inProgress:
        return Icons.sync;
      default:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final statusClr = widget.statusColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: statusClr.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusClr.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                _getIcon(report.status),
                color: statusClr,
                size: 19,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${report.incidentType} — ${report.location}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "By ${report.reporterName} · ${report.date.day}/${report.date.month}/${report.date.year}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: statusClr.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusClr.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: statusClr.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                report.statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusClr,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
