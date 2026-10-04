import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/audit_log_remote_data_source.dart';

enum ReportTimeframe { allTime, thisMonth, last30Days, thisWeek }

class ReportsAnalyticsPage extends StatefulWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  State<ReportsAnalyticsPage> createState() => _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends State<ReportsAnalyticsPage> {
  ReportTimeframe _selectedTimeframe = ReportTimeframe.allTime;
  String _searchQuery = "";
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidentBloc, IncidentState>(
      builder: (context, state) {
        final List<IncidentEntity> allIncidents =
            state is IncidentLoaded ? state.incidents : [];

        final List<IncidentEntity> filteredIncidents =
            _filterByTimeframe(allIncidents);

        final List<IncidentEntity> searchedIncidents = filteredIncidents.where((
          inc,
        ) {
          final q = _searchQuery.toLowerCase();
          return inc.id.toLowerCase().contains(q) ||
              inc.category.toLowerCase().contains(q) ||
              (inc.areaSector ?? '').toLowerCase().contains(q) ||
              (inc.resolvedAddress ?? '').toLowerCase().contains(q) ||
              (inc.reporterName ?? '').toLowerCase().contains(q) ||
              inc.status.toLowerCase().contains(q);
        }).toList();

        // Operational KPIs
        final int totalCount = filteredIncidents.length;
        final int solvedCount = filteredIncidents.where((i) => i.isSolved).length;
        final double resolutionRate = totalCount > 0
            ? (solvedCount / totalCount) * 100.0
            : 0.0;
        final int criticalCount = filteredIncidents.where((i) {
          final prio = (i.urgencyStatus ?? '').toLowerCase();
          return prio == 'critical' || prio == 'high' || i.upvoteCount >= 3;
        }).length;

        // Real Dynamic Average Response Speed calculation:
        // Elapsed duration between citizen report filing (timestamp) and dispatcher action (respondedAt)
        final respondedIncidents = filteredIncidents.where((i) {
          return i.respondedAt != null && (i.isInProgress || i.isSolved);
        }).toList();

        String avgResponseSpeed = "—";
        String responseSpeedSubtitle = "No dispatches recorded";
        if (respondedIncidents.isNotEmpty) {
          int totalMins = 0;
          int validSamples = 0;
          for (final inc in respondedIncidents) {
            final diff = inc.respondedAt!.difference(inc.timestamp).inMinutes;
            if (diff >= 0) {
              totalMins += diff;
              validSamples++;
            }
          }
          if (validSamples > 0) {
            final avgMins = (totalMins / validSamples).round();
            if (avgMins < 1) {
              avgResponseSpeed = "< 1 min";
            } else if (avgMins < 60) {
              avgResponseSpeed = "$avgMins min";
            } else {
              final hrs = (avgMins / 60).toStringAsFixed(1);
              avgResponseSpeed = "${hrs} hr";
            }
            responseSpeedSubtitle = "Based on $validSamples active dispatches";
          }
        }

        // Hotspot calculation
        final sectorCounts = <String, int>{};
        for (final inc in filteredIncidents) {
          final s = BarangaySectorHelper.normalizeSector(
            inc.areaSector,
            inc.resolvedAddress,
          );
          sectorCounts[s] = (sectorCounts[s] ?? 0) + 1;
        }
        String topHotspot = "N/A";
        int maxHotspotCount = 0;
        sectorCounts.forEach((sec, count) {
          if (count > maxHotspotCount) {
            maxHotspotCount = count;
            topHotspot = sec;
          }
        });

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Header & Actions Bar ───────────────────────────────
              _buildHeaderBar(context, filteredIncidents),
              const SizedBox(height: 24),

              // ── Timeframe Selector Bar ─────────────────────────────────
              _buildTimeframeSelector(),
              const SizedBox(height: 24),

              // ── KPI Summary Cards ──────────────────────────────────────
              _buildKpiCards(
                totalCount: totalCount,
                solvedCount: solvedCount,
                resolutionRate: resolutionRate,
                criticalCount: criticalCount,
                topHotspot: topHotspot,
                hotspotCount: maxHotspotCount,
                avgResponseSpeed: avgResponseSpeed,
                responseSpeedSubtitle: responseSpeedSubtitle,
              ),
              const SizedBox(height: 28),

              // ── Charts Row (Trend Curve & Sector Ranking) ───────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildTrendChartCard(filteredIncidents),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: _buildSectorRankingCard(sectorCounts, totalCount),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Incident Blotter Ledger Table ──────────────────────────
              _buildBlotterLedgerCard(searchedIncidents),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // ── Header Bar with Export Actions ─────────────────────────────────────
  Widget _buildHeaderBar(
    BuildContext context,
    List<IncidentEntity> filteredIncidents,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF0A84FF)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reports & Municipal Analytics Hub",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE8F0FE),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Barangay Moonwalk blotter ledger, sector load diagnostics, and certified LGU exports",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7B8DB0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // 1-Click CSV Export Button
            OutlinedButton.icon(
              onPressed: _isExporting
                  ? null
                  : () => _exportBlotterCsv(filteredIncidents),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00E5FF), width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.08),
              ),
              icon: const Icon(
                Icons.table_chart_outlined,
                size: 17,
                color: Color(0xFF00E5FF),
              ),
              label: const Text(
                "Export Blotter CSV",
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Official PDF Report Generator Button
            ElevatedButton.icon(
              onPressed: _isExporting
                  ? null
                  : () => _generateOfficialPdfReport(filteredIncidents),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                elevation: 4,
                shadowColor: const Color(0xFFFF3B30).withValues(alpha: 0.4),
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text(
                "Official PDF Report",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Timeframe Selector ─────────────────────────────────────────────────
  Widget _buildTimeframeSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1627),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2D4A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _timeframePill(
            "All Time",
            ReportTimeframe.allTime,
            Icons.all_inclusive_rounded,
          ),
          _timeframePill(
            "This Month",
            ReportTimeframe.thisMonth,
            Icons.calendar_month_rounded,
          ),
          _timeframePill(
            "Last 30 Days",
            ReportTimeframe.last30Days,
            Icons.history_toggle_off_rounded,
          ),
          _timeframePill(
            "This Week",
            ReportTimeframe.thisWeek,
            Icons.date_range_rounded,
          ),
        ],
      ),
    );
  }

  Widget _timeframePill(
    String title,
    ReportTimeframe tf,
    IconData icon,
  ) {
    final isSelected = _selectedTimeframe == tf;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeframe = tf),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A84FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0A84FF).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF7B8DB0),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF7B8DB0),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KPI Summary Cards ──────────────────────────────────────────────────
  Widget _buildKpiCards({
    required int totalCount,
    required int solvedCount,
    required double resolutionRate,
    required int criticalCount,
    required String topHotspot,
    required int hotspotCount,
    required String avgResponseSpeed,
    required String responseSpeedSubtitle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 1000;
        final cardWidth = isNarrow
            ? (constraints.maxWidth - 16) / 2
            : (constraints.maxWidth - 64) / 5;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _kpiCard(
              width: cardWidth,
              title: "Total Blotter Cases",
              value: "$totalCount",
              subtitle: "Recorded in period",
              icon: Icons.assignment_outlined,
              accentColor: const Color(0xFF0A84FF),
            ),
            _kpiCard(
              width: cardWidth,
              title: "Resolution Rate",
              value: "${resolutionRate.toStringAsFixed(1)}%",
              subtitle: "$solvedCount resolved cases",
              icon: Icons.verified_outlined,
              accentColor: const Color(0xFF30D158),
            ),
            _kpiCard(
              width: cardWidth,
              title: "Avg Response Speed",
              value: avgResponseSpeed,
              subtitle: responseSpeedSubtitle,
              icon: Icons.timer_outlined,
              accentColor: const Color(0xFF00E5FF),
            ),
            _kpiCard(
              width: cardWidth,
              title: "Top Hotspot Sector",
              value: topHotspot,
              subtitle: "$hotspotCount incidents recorded",
              icon: Icons.place_outlined,
              accentColor: const Color(0xFFFF9F0A),
            ),
            _kpiCard(
              width: cardWidth,
              title: "High / Critical",
              value: "$criticalCount",
              subtitle: "Immediate action tickets",
              icon: Icons.warning_amber_rounded,
              accentColor: const Color(0xFFFF3B30),
            ),
          ],
        );
      },
    );
  }

  Widget _kpiCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1627),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF1E2D4A).withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF7B8DB0),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE8F0FE),
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Incident Trend Curve Card ──────────────────────────────────────────
  Widget _buildTrendChartCard(List<IncidentEntity> incidents) {
    // Bucket incidents into the last 7 time units
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );

    final List<double> dailyTotals = [];
    for (final day in days) {
      final nextDay = day.add(const Duration(days: 1));
      final count = incidents.where((i) {
        return i.timestamp.isAfter(day) && i.timestamp.isBefore(nextDay);
      }).length;
      dailyTotals.add(count.toDouble());
    }

    final double maxVal = [...dailyTotals, 4.0].reduce(max);
    final dayLabels = days.map((d) => "${d.day}/${d.month}").toList();

    return Custom3dCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 22,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Incident Frequency Trend",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE8F0FE),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Daily incident frequency timeline within selected window",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7B8DB0),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  "${incidents.length} Records",
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: CustomPaint(
              size: Size.infinite,
              painter: _AnalyticsCurvePainter(
                data: dailyTotals,
                labels: dayLabels,
                maxValue: maxVal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sector Ranking Horizontal Bar Chart ────────────────────────────────
  Widget _buildSectorRankingCard(
    Map<String, int> sectorCounts,
    int totalCount,
  ) {
    final sortedSectors = sectorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Custom3dCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 22,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sector Incident Ranking",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE8F0FE),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Geographic incident load distribution",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7B8DB0),
                    ),
                  ),
                ],
              ),
              Icon(Icons.bar_chart_rounded, color: Color(0xFF0A84FF), size: 20),
            ],
          ),
          const SizedBox(height: 20),
          if (sortedSectors.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: const Text(
                "No sector logs found",
                style: TextStyle(color: Color(0xFF7B8DB0), fontSize: 12),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: min(5, sortedSectors.length),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = sortedSectors[index];
                final double pct =
                    totalCount > 0 ? (entry.value / totalCount) : 0.0;
                final bool isTop = index == 0;
                final barColor = isTop
                    ? const Color(0xFFFF5252)
                    : (index == 1
                        ? const Color(0xFFFFAB40)
                        : const Color(0xFF00E5FF));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: isTop
                                ? const Color(0xFFE8F0FE)
                                : const Color(0xFFB0C4DE),
                            fontSize: 12,
                            fontWeight:
                                isTop ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${entry.value} (${(pct * 100).toStringAsFixed(1)}%)",
                          style: TextStyle(
                            color: barColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        children: [
                          Container(
                            height: 7,
                            width: double.infinity,
                            color: const Color(0xFF060D1A),
                          ),
                          FractionallySizedBox(
                            widthFactor: pct.clamp(0.02, 1.0),
                            child: Container(
                              height: 7,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: barColor.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Blotter Ledger Table Card ──────────────────────────────────────────
  Widget _buildBlotterLedgerCard(List<IncidentEntity> incidents) {
    return Custom3dCard(
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
                    child: const Icon(
                      Icons.folder_shared_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Barangay Municipal Blotter Ledger",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE8F0FE),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Certified community incident register for dispatch accountability",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7B8DB0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Search Input
              SizedBox(
                width: 280,
                child: TextField(
                  style: const TextStyle(
                    color: Color(0xFFE8F0FE),
                    fontSize: 12.5,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search ledger records...",
                    hintStyle: const TextStyle(
                      color: Color(0xFF5A6E8C),
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF7B8DB0),
                      size: 18,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF060D1A),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF1E2D4A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF1E2D4A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF0A84FF),
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: const Color(0xFF1E2D4A)),
          const SizedBox(height: 12),

          if (incidents.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: const Text(
                "No matching incident ledger records in this timeframe.",
                style: TextStyle(color: Color(0xFF7B8DB0), fontSize: 13),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 46,
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFF060D1A)),
                dataRowColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.hovered)
                      ? const Color(0xFF0D1627).withValues(alpha: 0.8)
                      : Colors.transparent,
                ),
                dividerThickness: 0.5,
                columns: const [
                  DataColumn(
                    label: Text(
                      "Case ID",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7B8DB0),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Date & Time",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7B8DB0),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Emergency Category",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7B8DB0),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Sector / Address",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7B8DB0),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Complainant",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7B8DB0),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Status",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7B8DB0),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Dispatcher Remarks",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7B8DB0),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
                rows: incidents.map((inc) {
                  final statusClr = _statusColor(inc.status);
                  final d = inc.timestamp;
                  final dateStr =
                      "${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          inc.id.length > 8 ? inc.id.substring(0, 8) : inc.id,
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Color(0xFF7B8DB0),
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          inc.category,
                          style: const TextStyle(
                            color: Color(0xFFE8F0FE),
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 160,
                          child: Text(
                            inc.resolvedAddress ??
                                inc.areaSector ??
                                "GPS Coordinates Recorded",
                            style: const TextStyle(
                              color: Color(0xFFB0C4DE),
                              fontSize: 11.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          inc.isAnonymous
                              ? "Anonymous Citizen"
                              : (inc.reporterName ??
                                  inc.reporterEmail ??
                                  "Citizen"),
                          style: const TextStyle(
                            color: Color(0xFFE8F0FE),
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusClr.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusClr.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            inc.status.toUpperCase(),
                            style: TextStyle(
                              color: statusClr,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 180,
                          child: Text(
                            (inc.dispatcherNotes != null &&
                                    inc.dispatcherNotes!.isNotEmpty)
                                ? inc.dispatcherNotes!
                                : "—",
                            style: const TextStyle(
                              color: Color(0xFF7B8DB0),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ── CSV Blotter Export ──────────────────────────────────────────────────
  Future<void> _exportBlotterCsv(List<IncidentEntity> incidents) async {
    setState(() => _isExporting = true);
    try {
      final List<List<dynamic>> csvRows = [
        [
          "Case ID",
          "Timestamp",
          "Category",
          "Priority",
          "Status",
          "Barangay Sector",
          "Resolved Address",
          "Latitude",
          "Longitude",
          "Complainant Name",
          "Is Anonymous",
          "Corroboration Upvotes",
          "Dispatcher Remarks",
        ],
      ];

      for (final inc in incidents) {
        csvRows.add([
          inc.id,
          inc.timestamp.toIso8601String(),
          inc.category,
          inc.urgencyStatus ?? 'Normal',
          inc.status,
          BarangaySectorHelper.normalizeSector(
            inc.areaSector,
            inc.resolvedAddress,
          ),
          inc.resolvedAddress ?? '',
          inc.latitude,
          inc.longitude,
          inc.isAnonymous ? 'Anonymous' : (inc.reporterName ?? ''),
          inc.isAnonymous ? 'YES' : 'NO',
          inc.upvoteCount,
          inc.dispatcherNotes ?? '',
        ]);
      }

      final csvString = const ListToCsvConverter().convert(csvRows);
      final bytes = Uint8List.fromList(utf8.encode(csvString));

      final filename =
          "Barangay_Moonwalk_Blotter_${DateTime.now().millisecondsSinceEpoch}.csv";

      await Printing.sharePdf(bytes: bytes, filename: filename);

      await sl<AuditLogRemoteDataSource>().recordLog(
        actionType: 'Report Export',
        details: 'Exported blotter ledger CSV with ${incidents.length} incident records.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✓ Blotter ledger CSV exported successfully: $filename"),
            backgroundColor: const Color(0xFF30D158),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to export CSV: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ── Official Printable PDF Report Generator ────────────────────────────
  Future<void> _generateOfficialPdfReport(
    List<IncidentEntity> incidents,
  ) async {
    setState(() => _isExporting = true);
    try {
      final pdf = pw.Document();

      final int total = incidents.length;
      final int solved = incidents.where((i) => i.isSolved).length;
      final int pending = incidents.where((i) => i.isPending).length;
      final int inProgress = incidents.where((i) => i.isInProgress).length;
      final double resRate = total > 0 ? (solved / total) * 100 : 0.0;

      final now = DateTime.now();
      final datePrinted = "${now.day}/${now.month}/${now.year}";

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (pw.Context pdfContext) {
            return [
              // 1. Official Header / Seal
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "REPUBLIC OF THE PHILIPPINES",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      "CITY OF PARAÑAQUE",
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.Text(
                      "BARANGAY MOONWALK DISPATCH COMMAND CENTER",
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      "ResQ Civic Defense & Community Safety Monitoring Desk",
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      height: 1.5,
                      color: PdfColors.blue900,
                      width: double.infinity,
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      "OFFICIAL MUNICIPAL INCIDENT BLOTTER REPORT",
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      "Generated: $datePrinted | Filter Window: ${_timeframeTitle(_selectedTimeframe)}",
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // 2. Executive Summary Block
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(6),
                  color: PdfColors.grey100,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _pdfMetricItem("Total Incidents", "$total"),
                    _pdfMetricItem("Solved Cases", "$solved"),
                    _pdfMetricItem("In Progress", "$inProgress"),
                    _pdfMetricItem("Pending Dispatch", "$pending"),
                    _pdfMetricItem(
                      "Resolution Rate",
                      "${resRate.toStringAsFixed(1)}%",
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // 3. Certified Incident Blotter Ledger Table
              pw.Text(
                "CERTIFIED INCIDENT LEDGER ENTRIES",
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 8),

              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                cellStyle: const pw.TextStyle(fontSize: 7.5),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 4,
                ),
                headers: [
                  "Case ID",
                  "Date/Time",
                  "Category",
                  "Sector / Location",
                  "Complainant",
                  "Status",
                  "Remarks",
                ],
                data: incidents.map((inc) {
                  final dt = inc.timestamp;
                  final dStr =
                      "${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                  return [
                    inc.id.length > 8 ? inc.id.substring(0, 8) : inc.id,
                    dStr,
                    inc.category,
                    inc.resolvedAddress ?? inc.areaSector ?? 'Barangay Moonwalk',
                    inc.isAnonymous
                        ? "Anonymous"
                        : (inc.reporterName ?? "Citizen"),
                    inc.status.toUpperCase(),
                    inc.dispatcherNotes ?? "—",
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 28),

              // 4. Attestation & Sign-off Block
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Prepared & Certified by:",
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 32),
                      pw.Container(width: 180, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "DUTY DISPATCH OFFICER",
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "Barangay Moonwalk Opcen Desk",
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Attested & Approved by:",
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 32),
                      pw.Container(width: 180, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "HON. PUNONG BARANGAY",
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "Barangay Captain, Moonwalk Parañaque",
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      // Open in-browser print / save PDF preview dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Barangay_Moonwalk_Blotter_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      await sl<AuditLogRemoteDataSource>().recordLog(
        actionType: 'Report Export',
        details: 'Generated official municipal PDF blotter report with ${incidents.length} incident records.',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to generate PDF report: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  static pw.Widget _pdfMetricItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],
    );
  }

  // ── Helper Filtering Methods ───────────────────────────────────────────
  List<IncidentEntity> _filterByTimeframe(List<IncidentEntity> incidents) {
    final now = DateTime.now();
    switch (_selectedTimeframe) {
      case ReportTimeframe.allTime:
        return incidents;
      case ReportTimeframe.thisMonth:
        return incidents.where((i) {
          return i.timestamp.year == now.year && i.timestamp.month == now.month;
        }).toList();
      case ReportTimeframe.last30Days:
        final cutoff = now.subtract(const Duration(days: 30));
        return incidents.where((i) => i.timestamp.isAfter(cutoff)).toList();
      case ReportTimeframe.thisWeek:
        final cutoff = now.subtract(const Duration(days: 7));
        return incidents.where((i) => i.timestamp.isAfter(cutoff)).toList();
    }
  }

  String _timeframeTitle(ReportTimeframe tf) {
    switch (tf) {
      case ReportTimeframe.allTime:
        return "All Historical Records";
      case ReportTimeframe.thisMonth:
        return "Current Calendar Month";
      case ReportTimeframe.last30Days:
        return "Previous 30 Days";
      case ReportTimeframe.thisWeek:
        return "Previous 7 Days";
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'solved':
      case 'resolved':
        return const Color(0xFF30D158);
      case 'inprogress':
      case 'in progress':
        return const Color(0xFF00E5FF);
      case 'spam':
        return const Color(0xFFFF453A);
      default:
        return const Color(0xFFFF9F0A);
    }
  }
}

class _AnalyticsCurvePainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final double maxValue;

  _AnalyticsCurvePainter({
    required this.data,
    required this.labels,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    const double leftMargin = 30.0;
    const double bottomMargin = 20.0;
    final double graphWidth = width - leftMargin;
    final double graphHeight = height - bottomMargin;

    final Paint gridPaint = Paint()
      ..color = const Color(0xFF1E2D4A).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const int gridRows = 3;
    for (int i = 0; i <= gridRows; i++) {
      final double y = (graphHeight / gridRows) * i;
      canvas.drawLine(Offset(leftMargin, y), Offset(width, y), gridPaint);

      final val = maxValue - ((maxValue / gridRows) * i);
      textPainter.text = TextSpan(
        text: val.round().toString(),
        style: const TextStyle(color: Color(0xFF5A6E8C), fontSize: 9.5),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(4, y - 6));
    }

    final double xSpacing = graphWidth / (labels.length - 1);
    for (int i = 0; i < labels.length; i++) {
      final double x = leftMargin + (xSpacing * i);
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Color(0xFF5A6E8C), fontSize: 9.5),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - (textPainter.width / 2), graphHeight + 6),
      );
    }

    if (data.isEmpty) return;

    double getY(double val) {
      if (maxValue <= 0) return graphHeight;
      return graphHeight - ((val / maxValue).clamp(0.0, 1.0) * graphHeight);
    }

    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final double x = leftMargin + (xSpacing * i);
      final double y = getY(data[i]);
      points.add(Offset(x, y));
    }

    final Path path = Path()..moveTo(points[0].dx, points[0].dy);
    final Path areaPath = Path()..moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx1 = p0.dx + (p1.dx - p0.dx) / 2;
      final cy1 = p0.dy;
      final cx2 = p0.dx + (p1.dx - p0.dx) / 2;
      final cy2 = p1.dy;
      path.cubicTo(cx1, cy1, cx2, cy2, p1.dx, p1.dy);
      areaPath.cubicTo(cx1, cy1, cx2, cy2, p1.dx, p1.dy);
    }

    areaPath.lineTo(points.last.dx, graphHeight);
    areaPath.lineTo(points.first.dx, graphHeight);
    areaPath.close();

    final Paint areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.25),
          const Color(0xFF00E5FF).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTRB(leftMargin, 0, points.last.dx, graphHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, areaPaint);

    final Paint linePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawPath(path, linePaint);

    final Paint dotFill = Paint()
      ..color = const Color(0xFF0D1627)
      ..style = PaintingStyle.fill;

    final Paint dotBorder = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final pt in points) {
      canvas.drawCircle(pt, 3.5, dotFill);
      canvas.drawCircle(pt, 3.5, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _AnalyticsCurvePainter oldDelegate) => true;
}
