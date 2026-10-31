import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/audit_log_remote_data_source.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';

enum ReportTimeframe { allTime, thisMonth, last30Days, thisWeek }

class ReportsAnalyticsPage extends StatefulWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  State<ReportsAnalyticsPage> createState() => _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends State<ReportsAnalyticsPage> {
  ReportTimeframe _selectedTimeframe = ReportTimeframe.allTime;
  String _searchQuery = "";
  bool _blotterOnly = false;
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
          if (_blotterOnly && !inc.isBlotter) return false;
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
              avgResponseSpeed = "$hrs hr";
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Header & Actions Bar ───────────────────────────────
              _buildHeaderBar(context, filteredIncidents),
              const SizedBox(height: 20),

              // ── Timeframe Selector Bar ─────────────────────────────────
              _buildTimeframeSelector(),
              const SizedBox(height: 20),

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
              const SizedBox(height: 20),

              // ── Charts Row (Trend Curve & Sector Ranking) ───────────────
              // Side by side (same height) on wide screens, stacked on
              // narrow ones.
              LayoutBuilder(
                builder: (context, constraints) {
                  final Widget trendCard = _buildTrendChartCard(
                    filteredIncidents,
                  );
                  final Widget rankingCard = _buildSectorRankingCard(
                    sectorCounts,
                    totalCount,
                  );
                  if (constraints.maxWidth < 760) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        trendCard,
                        const SizedBox(height: 18),
                        rankingCard,
                      ],
                    );
                  }
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 6, child: trendCard),
                        const SizedBox(width: 18),
                        Expanded(flex: 4, child: rankingCard),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

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
    return AdminPageTitle(
      title: "Reports & Municipal Analytics Hub",
      subtitle:
          "Barangay Moonwalk blotter ledger, sector load diagnostics, and certified LGU exports",
      trailing: [
        // 1-Click CSV Export Button
        AdminButton(
          label: "Export Blotter CSV",
          icon: Icons.table_chart_outlined,
          style: AdminButtonStyle.ghost,
          onPressed: _isExporting
              ? null
              : () => _exportBlotterCsv(filteredIncidents),
        ),
        // Official PDF Report Generator Button
        AdminButton(
          label: "Official PDF Report",
          icon: Icons.picture_as_pdf_rounded,
          onPressed: _isExporting
              ? null
              : () => _generateOfficialPdfReport(filteredIncidents),
        ),
      ],
    );
  }

  // ── Timeframe Selector ─────────────────────────────────────────────────
  Widget _buildTimeframeSelector() {
    // Scrolls sideways on narrow phones instead of overflowing.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: AdminSegmented<ReportTimeframe>(
        segments: const [
          (ReportTimeframe.allTime, "All Time"),
          (ReportTimeframe.thisMonth, "This Month"),
          (ReportTimeframe.last30Days, "Last 30 Days"),
          (ReportTimeframe.thisWeek, "This Week"),
        ],
        value: _selectedTimeframe,
        onChanged: (tf) => setState(() => _selectedTimeframe = tf),
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
    final List<Widget> tiles = [
      _KpiTile(
        title: "Total Blotter Cases",
        value: "$totalCount",
        subtitle: "Recorded in period",
        icon: Icons.assignment_outlined,
        accentColor: AdminColors.primary,
      ),
      _KpiTile(
        title: "Resolution Rate",
        value: "${resolutionRate.toStringAsFixed(1)}%",
        subtitle: "$solvedCount resolved cases",
        icon: Icons.verified_outlined,
        accentColor: AdminColors.success,
        valueColor: AdminColors.successText,
        progress: resolutionRate / 100,
      ),
      _KpiTile(
        title: "Avg Response Speed",
        value: avgResponseSpeed,
        subtitle: responseSpeedSubtitle,
        icon: Icons.timer_outlined,
        accentColor: AdminColors.cyan,
        valueColor: AdminColors.cyanSoft,
        edged: true,
      ),
      _KpiTile(
        title: "Top Hotspot Sector",
        value: topHotspot,
        subtitle: "$hotspotCount incidents recorded",
        icon: Icons.place_outlined,
        accentColor: AdminColors.amber,
        compact: true,
      ),
      _KpiTile(
        title: "High / Critical",
        value: "$criticalCount",
        subtitle: "Immediate action tickets",
        icon: Icons.warning_amber_rounded,
        accentColor: AdminColors.danger,
        highlight: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // As many 170px-wide tiles as fit (two to five per row); the tiles
        // in a row share one height.
        const double gap = 14;
        final int fit = ((constraints.maxWidth + gap) / (170 + gap)).floor();
        final int columns = max(2, min(tiles.length, fit));
        final double tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int start = 0; start < tiles.length; start += columns) ...[
              if (start > 0) const SizedBox(height: gap),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (
                      int i = start;
                      i < min(start + columns, tiles.length);
                      i++
                    ) ...[
                      if (i > start) const SizedBox(width: gap),
                      SizedBox(width: tileWidth, child: tiles[i]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
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

    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionTitle(
            title: "Incident Frequency Trend",
            subtitle:
                "Daily incident frequency timeline within selected window",
            trailing: AdminPill(
              label: "${incidents.length} Records",
              tone: AdminTone.cyan,
            ),
          ),
          const SizedBox(height: 20),
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

    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminSectionTitle(
            title: "Sector Incident Ranking",
            subtitle: "Geographic incident load distribution",
          ),
          const SizedBox(height: 18),
          if (sortedSectors.isEmpty)
            const AdminEmptyState(
              icon: Icons.bar_chart_rounded,
              title: "No sector logs found",
            )
          else
            // A plain column rather than a list view, so the card can match
            // the height of the trend card beside it.
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (
                  int index = 0;
                  index < min(5, sortedSectors.length);
                  index++
                ) ...[
                  if (index > 0) const SizedBox(height: 12),
                  _buildSectorBar(sortedSectors[index], index, totalCount),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectorBar(
    MapEntry<String, int> entry,
    int index,
    int totalCount,
  ) {
    final double pct = totalCount > 0 ? (entry.value / totalCount) : 0.0;
    final bool isTop = index == 0;
    // The busiest sector runs red to orange, the rest blue to cyan.
    final List<Color> barColors = isTop
        ? const [AdminColors.danger, AdminColors.orange]
        : const [AdminColors.primary, AdminColors.cyan];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.key,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isTop ? AdminColors.textStrong : AdminColors.textBody,
                  fontSize: 13,
                  fontWeight: isTop ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "${entry.value} (${(pct * 100).toStringAsFixed(1)}%)",
              style: const TextStyle(
                color: AdminColors.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              FractionallySizedBox(
                widthFactor: pct.clamp(0.02, 1.0),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: barColors),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Blotter Ledger Table Card ──────────────────────────────────────────
  Widget _buildBlotterLedgerCard(List<IncidentEntity> incidents) {
    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth >= 640;
              // One Flex for both layouts, so the search field keeps its
              // text when the width crosses the breakpoint.
              return Flex(
                direction: wide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: wide
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    flex: wide ? 1 : 0,
                    fit: FlexFit.tight,
                    child: const AdminSectionTitle(
                      title: "Barangay Municipal Blotter Ledger",
                      subtitle:
                          "Certified community incident register for dispatch accountability",
                    ),
                  ),
                  const SizedBox(width: 14, height: 14),
                  // Search Input
                  SizedBox(
                    width: wide ? 300 : null,
                    child: AdminSearchField(
                      hint: "Search ledger records...",
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AdminSegmented<bool>(
              segments: const [
                (false, "All Reports"),
                (true, "Blotter Entries"),
              ],
              value: _blotterOnly,
              onChanged: (v) => setState(() => _blotterOnly = v),
            ),
          ),
          const SizedBox(height: 16),

          if (incidents.isEmpty)
            AdminEmptyState(
              icon: Icons.folder_open_rounded,
              title: _blotterOnly
                  ? "No blotter entries match in this timeframe."
                  : "No matching incident ledger records in this timeframe.",
            )
          else
            _buildLedgerTable(incidents),
        ],
      ),
    );
  }

  Widget _buildLedgerTable(List<IncidentEntity> incidents) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      // Fills the card on wide screens and scrolls sideways on narrow ones.
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DividerTheme(
              data: const DividerThemeData(color: AdminTable.divider),
              child: DataTable(
                headingRowHeight: 46,
                headingRowColor: WidgetStateProperty.all(
                  Colors.white.withValues(alpha: 0.04),
                ),
                dataRowColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.hovered)
                      ? AdminTable.hoverRow
                      : Colors.transparent,
                ),
                dividerThickness: 1,
                horizontalMargin: 16,
                columnSpacing: 28,
                columns: [
                  _tableColumn("Case ID"),
                  _tableColumn("Date & Time"),
                  _tableColumn("Emergency Category"),
                  _tableColumn("Sector / Address"),
                  _tableColumn("Complainant"),
                  _tableColumn("Status"),
                  _tableColumn("Dispatcher Remarks"),
                ],
                rows: incidents.map((inc) {
                  final statusTone = _statusTone(inc.status);
                  final d = inc.timestamp;
                  final dateStr =
                      "${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          inc.id.length > 8 ? inc.id.substring(0, 8) : inc.id,
                          style: AdminTable.cellStrong,
                        ),
                      ),
                      DataCell(Text(dateStr, style: AdminTable.cellMuted)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(inc.category, style: AdminTable.cell),
                            if (inc.isBlotter) ...[
                              const SizedBox(width: 8),
                              const AdminPill(
                                label: "BLOTTER",
                                tone: AdminTone.violet,
                                icon: Icons.gavel_rounded,
                              ),
                            ],
                          ],
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 160,
                          child: Text(
                            inc.resolvedAddress ??
                                inc.areaSector ??
                                "GPS Coordinates Recorded",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AdminTable.cell,
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
                          style: AdminTable.cell,
                        ),
                      ),
                      DataCell(
                        AdminPill(
                          label: inc.status.toUpperCase(),
                          tone: statusTone,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AdminTable.cellMuted,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A table heading, in capitals as on the board.
  DataColumn _tableColumn(String label) {
    return DataColumn(
      label: Text(label.toUpperCase(), style: AdminTable.header),
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
          "Blotter Entry",
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
          inc.isBlotter ? 'YES' : 'NO',
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
            backgroundColor: AdminColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to export CSV: $e"),
            backgroundColor: AdminColors.danger,
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
                    inc.isBlotter ? "${inc.category} (Blotter)" : inc.category,
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
            backgroundColor: AdminColors.danger,
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

  AdminTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'solved':
      case 'resolved':
        return AdminTone.green;
      case 'inprogress':
      case 'in progress':
        return AdminTone.blue;
      case 'spam':
        return AdminTone.slate;
      default:
        return AdminTone.yellow;
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
      ..color = Colors.white.withValues(alpha: 0.08)
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
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: AdminColors.chartAxis,
          fontSize: 9.5,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(4, y - 6));
    }

    final double xSpacing = graphWidth / (labels.length - 1);
    for (int i = 0; i < labels.length; i++) {
      final double x = leftMargin + (xSpacing * i);
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: AdminColors.chartAxis,
          fontSize: 9.5,
        ),
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
          AdminColors.cyan.withValues(alpha: 0.35),
          AdminColors.cyan.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTRB(leftMargin, 0, points.last.dx, graphHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, areaPaint);

    final Paint linePaint = Paint()
      ..color = AdminColors.cyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawPath(path, linePaint);

    final Paint dotFill = Paint()
      ..color = AdminColors.cardBackground
      ..style = PaintingStyle.fill;

    final Paint dotBorder = Paint()
      ..color = AdminColors.cyan
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

/// A KPI tile in the dashboard's stat card style, with a line of context
/// under the figure. [progress] (0 to 1) adds a thin bar under the figure,
/// [edged] tints the edge with [accentColor], [highlight] washes the tile red
/// and [compact] sets a smaller figure that may wrap, for a name.
class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.valueColor = AdminColors.textStrong,
    this.progress,
    this.edged = false,
    this.highlight = false,
    this.compact = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color valueColor;
  final double? progress;
  final bool edged;
  final bool highlight;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = highlight
        ? AdminColors.dangerPale
        : AdminColors.textLight;
    final TextStyle valueStyle = TextStyle(
      color: valueColor,
      fontSize: compact ? 20 : 30,
      fontWeight: FontWeight.w800,
      height: compact ? 1.2 : 1.1,
      letterSpacing: -0.5,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? null : AdminColors.cardBackground,
        gradient: highlight
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.alphaBlend(
                    AdminColors.critical.withValues(alpha: 0.18),
                    AdminColors.cardBackground,
                  ),
                  Color.alphaBlend(
                    AdminColors.critical.withValues(alpha: 0.06),
                    AdminColors.cardBackground,
                  ),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight
              ? AdminColors.dangerSoft.withValues(alpha: 0.4)
              : edged
              ? accentColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          if (highlight)
            BoxShadow(
              color: AdminColors.critical.withValues(alpha: 0.18),
              blurRadius: 26,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(
                        alpha: highlight ? 0.3 : 0.2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: highlight
                          ? AdminColors.dangerPale
                          : Color.lerp(accentColor, Colors.white, 0.55),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (compact)
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: valueStyle,
                )
              else
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(value, maxLines: 1, style: valueStyle),
                ),
              if (progress != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress!.clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentColor, valueColor],
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
