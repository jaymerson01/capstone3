import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/core/utils/incident_triage_helper.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/presentation/widgets/in_app_evidence_player_dialog.dart';
import 'package:community_safety_app/core/presentation/widgets/in_app_image_viewer_dialog.dart';

class IncidentReportsPage extends StatefulWidget {
  const IncidentReportsPage({super.key});

  @override
  State<IncidentReportsPage> createState() => _IncidentReportsPageState();
}

class _IncidentReportsPageState extends State<IncidentReportsPage> {
  String searchQuery = "";
  String statusFilter = "All";
  bool showArchivedReports = false;
  String sortBy = "latest"; // 'latest', 'urgency', 'corroborated', 'oldest_pending'
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Incident Reports",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE8F0FE),
                ),
              ),
              Row(
                children: [
                  Text(
                    showArchivedReports ? "Archived" : "Active",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF7B8DB0),
                    ),
                  ),
                  SizedBox(width: 8),
                  Switch(
                    value: showArchivedReports,
                    activeTrackColor: const Color(0xFF0A84FF),
                    activeThumbColor: Colors.white,
                    onChanged: (val) {
                      setState(() {
                        showArchivedReports = val;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1627),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E2D4A)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    style: const TextStyle(
                        color: Color(0xFFE8F0FE), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Search by ID, type, reporter, location...",
                      hintStyle: const TextStyle(
                          color: Color(0xFF4A5568), fontSize: 12.5),
                      prefixIcon: Icon(Icons.search,
                          color: Color(0xFF7B8DB0), size: 20),
                      filled: true,
                      fillColor: const Color(0xFF0D1627),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Color(0xFF1E2D4A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Color(0xFF1E2D4A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Color(0xFF0A84FF), width: 2),
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => searchQuery = value),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1627),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2D4A)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: statusFilter,
                    dropdownColor: const Color(0xFF0D1627),
                    style: const TextStyle(
                        color: Color(0xFFE8F0FE), fontSize: 13),
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF0A84FF)),
                    items: const [
                      DropdownMenuItem(
                          value: "All", child: Text("All Statuses")),
                      DropdownMenuItem(
                          value: "Pending", child: Text("Pending")),
                      DropdownMenuItem(
                          value: "In Progress", child: Text("In Progress")),
                      DropdownMenuItem(
                          value: "Solved", child: Text("Solved")),
                      DropdownMenuItem(
                          value: "Spam", child: Text("Spam")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => statusFilter = value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          // Priority Triage Hierarchy Toolbar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  "PRIORITY QUEUE:",
                  style: TextStyle(
                    color: Color(0xFF7B8DB0),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(width: 10),
                _buildSortChip(
                  key: "latest",
                  label: "Latest First",
                  icon: Icons.access_time_rounded,
                  activeColor: const Color(0xFF0A84FF),
                ),
                SizedBox(width: 8),
                _buildSortChip(
                  key: "urgency",
                  label: "Critical & Urgent First",
                  icon: Icons.warning_amber_rounded,
                  activeColor: const Color(0xFFFF3B30),
                ),
                SizedBox(width: 8),
                _buildSortChip(
                  key: "corroborated",
                  label: "Most Corroborated / Affected",
                  icon: Icons.people_alt_outlined,
                  activeColor: const Color(0xFF00E5FF),
                ),
                SizedBox(width: 8),
                _buildSortChip(
                  key: "oldest_pending",
                  label: "Oldest Pending Backlog",
                  icon: Icons.hourglass_top_rounded,
                  activeColor: const Color(0xFFFF9500),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<IncidentBloc, IncidentState>(
              builder: (context, state) {
                if (state is IncidentLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is IncidentError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is IncidentLoaded) {
                  final filteredReports = state.incidents.where((report) {
                    final isArchived =
                        report.status.toLowerCase() == 'archived';
                    if (showArchivedReports && !isArchived) return false;
                    if (!showArchivedReports && isArchived) return false;

                    final matchesSearch = report.id
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        report.category
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        report.reporterId
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        (report.reporterName ?? "")
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        (report.resolvedAddress ?? "")
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        (report.areaSector ?? "")
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase());

                    final reportStatusLabel =
                        _getStatusLabel(report.status);
                    final matchesStatus = statusFilter == "All" ||
                        reportStatusLabel == statusFilter;

                    return matchesSearch && matchesStatus;
                  }).toList();

                  // Apply Multi-Criteria Sorting Hierarchy
                  if (_sortColumnIndex != null) {
                    if (_sortColumnIndex == 2) {
                      // Sort by Urgency Weight
                      filteredReports.sort((a, b) {
                        final wa = IncidentTriageHelper.getUrgencyWeight(a.urgencyStatus);
                        final wb = IncidentTriageHelper.getUrgencyWeight(b.urgencyStatus);
                        return _sortAscending ? wa.compareTo(wb) : wb.compareTo(wa);
                      });
                    } else if (_sortColumnIndex == 3) {
                      // Sort by Corroborated / Affected count
                      filteredReports.sort((a, b) => _sortAscending
                          ? a.upvoteCount.compareTo(b.upvoteCount)
                          : b.upvoteCount.compareTo(a.upvoteCount));
                    } else if (_sortColumnIndex == 6) {
                      // Sort by Date
                      filteredReports.sort((a, b) => _sortAscending
                          ? a.timestamp.compareTo(b.timestamp)
                          : b.timestamp.compareTo(a.timestamp));
                    }
                  } else {
                    switch (sortBy) {
                      case "urgency":
                        filteredReports.sort((a, b) {
                          final wa = IncidentTriageHelper.getUrgencyWeight(a.urgencyStatus);
                          final wb = IncidentTriageHelper.getUrgencyWeight(b.urgencyStatus);
                          final cmp = wb.compareTo(wa);
                          return cmp != 0 ? cmp : b.timestamp.compareTo(a.timestamp);
                        });
                        break;
                      case "corroborated":
                        filteredReports.sort((a, b) {
                          final cmp = b.upvoteCount.compareTo(a.upvoteCount);
                          return cmp != 0 ? cmp : b.timestamp.compareTo(a.timestamp);
                        });
                        break;
                      case "oldest_pending":
                        filteredReports.sort((a, b) {
                          final aPending = a.status.toLowerCase() == 'pending' ? 0 : 1;
                          final bPending = b.status.toLowerCase() == 'pending' ? 0 : 1;
                          if (aPending != bPending) return aPending.compareTo(bPending);
                          return a.timestamp.compareTo(b.timestamp);
                        });
                        break;
                      case "latest":
                      default:
                        filteredReports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                        break;
                    }
                  }

                  return Custom3dCard(
                    padding: const EdgeInsets.all(12),
                    borderRadius: 22,
                    child: filteredReports.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    color: const Color(0xFF2A3F60),
                                    size: 56),
                                SizedBox(height: 14),
                                Text(
                                  "No incident reports found",
                                  style: TextStyle(
                                    color: Color(0xFF7B8DB0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Horizontally scrollable metadata columns
                                Expanded(
                                  child: Scrollbar(
                                    controller: _horizontalScrollController,
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                      controller: _horizontalScrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        headingRowHeight: 50,
                                        dataRowMinHeight: 60,
                                        dataRowMaxHeight: 60,
                                        headingRowColor:
                                            WidgetStateProperty.all(
                                                const Color(0xFF060D1A)),
                                        dataRowColor:
                                            WidgetStateProperty.resolveWith(
                                                (states) => states.contains(
                                                        WidgetState.hovered)
                                                    ? const Color(0xFF0D1627)
                                                        .withValues(alpha: 0.8)
                                                    : Colors.transparent),
                                        dividerThickness: 0.5,
                                        sortColumnIndex: _sortColumnIndex,
                                        sortAscending: _sortAscending,
                                        columns: [
                                          const DataColumn(
                                              label: Text("Report ID",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF7B8DB0),
                                                      fontSize: 12))),
                                          const DataColumn(
                                              label: Text("Category",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF7B8DB0),
                                                      fontSize: 12))),
                                          DataColumn(
                                              label: Text("Urgency",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF7B8DB0),
                                                      fontSize: 12)),
                                              onSort:
                                                  (columnIndex, ascending) {
                                                setState(() {
                                                  _sortColumnIndex =
                                                      columnIndex;
                                                  _sortAscending = ascending;
                                                });
                                              }),
                                          DataColumn(
                                              label: Text(
                                                  "Corroborated / Affected",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF7B8DB0),
                                                      fontSize: 12)),
                                              onSort:
                                                  (columnIndex, ascending) {
                                                setState(() {
                                                  _sortColumnIndex =
                                                      columnIndex;
                                                  _sortAscending = ascending;
                                                });
                                              }),
                                          const DataColumn(
                                              label: Text("Reporter",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF7B8DB0),
                                                      fontSize: 12))),
                                          const DataColumn(
                                              label: Text("Location",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF7B8DB0),
                                                      fontSize: 12))),
                                          DataColumn(
                                              label: Text("Date",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF7B8DB0),
                                                      fontSize: 12)),
                                              onSort:
                                                  (columnIndex, ascending) {
                                                setState(() {
                                                  _sortColumnIndex =
                                                      columnIndex;
                                                  _sortAscending = ascending;
                                                });
                                              }),
                                          const DataColumn(
                                              label: Text("Status",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF7B8DB0),
                                                      fontSize: 12))),
                                        ],
                                        rows: filteredReports.map((report) {
                                          final statusColor =
                                              _getStatusColor(report.status);
                                          final statusLabel =
                                              _getStatusLabel(report.status);

                                          final urgency = report
                                                  .urgencyStatus
                                                  ?.toUpperCase() ??
                                              "PENDING";
                                          final urgencyColor =
                                              _getUrgencyColor(urgency);

                                          final reporterDisplayName =
                                              (report.reporterName != null &&
                                                      report.reporterName!
                                                          .isNotEmpty)
                                                  ? report.reporterName!
                                                  : (report.reporterId.length > 8
                                                      ? report.reporterId
                                                          .substring(0, 8)
                                                      : report.reporterId);

                                          final locationDisplay =
                                              BarangaySectorHelper.formatReadableAddress(
                                            resolvedAddress: report.resolvedAddress,
                                            areaSector: report.areaSector,
                                            latitude: report.latitude,
                                            longitude: report.longitude,
                                          );

                                          return DataRow(
                                            cells: [
                                              DataCell(Text(
                                                  report.id.length > 8
                                                      ? report.id.substring(0, 8)
                                                      : report.id,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFFE8F0FE),
                                                      fontSize: 12))),
                                              DataCell(Text(report.category,
                                                  style: const TextStyle(
                                                      color: Color(0xFFE8F0FE),
                                                      fontSize: 12))),
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: urgencyColor
                                                        .withValues(
                                                            alpha: 0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                    border: Border.all(
                                                        color: urgencyColor
                                                            .withValues(
                                                                alpha: 0.35)),
                                                  ),
                                                  child: Text(
                                                    urgency,
                                                    style: TextStyle(
                                                      color: urgencyColor,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 10.5,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF00E5FF)
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: (report.upvoteCount + 1) >= 5
                                                          ? const Color(0xFFFF3B30).withValues(alpha: 0.5)
                                                          : ((report.upvoteCount + 1) >= 3
                                                              ? const Color(0xFFFF9500).withValues(alpha: 0.5)
                                                              : const Color(0xFF00E5FF).withValues(alpha: 0.35)),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .people_alt_outlined,
                                                        size: 13,
                                                        color: (report.upvoteCount + 1) >= 5
                                                            ? const Color(0xFFFF3B30)
                                                            : ((report.upvoteCount + 1) >= 3
                                                                ? const Color(0xFFFF9500)
                                                                : const Color(0xFF00E5FF)),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        "${report.upvoteCount + 1} Affected",
                                                        style: TextStyle(
                                                          color: (report.upvoteCount + 1) >= 5
                                                              ? const Color(0xFFFF3B30)
                                                              : ((report.upvoteCount + 1) >= 3
                                                                  ? const Color(0xFFFF9500)
                                                                  : const Color(0xFF00E5FF)),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      reporterDisplayName,
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFFE8F0FE),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    if (report
                                                        .isReportingOnBehalf)
                                                      Text(
                                                        "👥 For: ${report.victimName ?? 'Relative'}",
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFFFF9500),
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )
                                                    else if (report.isAnonymous)
                                                      Text(
                                                        "Anon to Public",
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFFFF9500),
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Tooltip(
                                                  message: locationDisplay,
                                                  child: SizedBox(
                                                    width: 140,
                                                    child: Text(
                                                      locationDisplay,
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xFF7B8DB0),
                                                          fontSize: 12),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(Text(
                                                  _formatDate(report.timestamp),
                                                  style: const TextStyle(
                                                      color: Color(0xFF7B8DB0),
                                                      fontSize: 12))),
                                              DataCell(
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: statusColor
                                                            .withValues(
                                                                alpha: 0.12),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                20),
                                                        border: Border.all(
                                                            color: statusColor
                                                                .withValues(
                                                                    alpha:
                                                                        0.3)),
                                                      ),
                                                      child: Text(
                                                        statusLabel,
                                                        style: TextStyle(
                                                          color: statusColor,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                    if (report.isInProgress &&
                                                        report.estimatedResponseTime !=
                                                            null &&
                                                        report
                                                            .estimatedResponseTime!
                                                            .isNotEmpty) ...[
                                                      SizedBox(height: 3),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                              Icons.timer_outlined,
                                                              size: 11,
                                                              color: Color(
                                                                  0xFF00E5FF)),
                                                          SizedBox(
                                                              width: 3),
                                                          Text(
                                                            "ETA: ${report.estimatedResponseTime!}",
                                                            style:
                                                                const TextStyle(
                                                              color: Color(
                                                                  0xFF00E5FF),
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                // Sticky / Frozen Actions Column on the far right
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF060D1A),
                                    border: Border(
                                      left: BorderSide(
                                        color: Color(0xFF1E293B),
                                        width: 1.5,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black38,
                                        blurRadius: 6,
                                        offset: Offset(-2, 0),
                                      ),
                                    ],
                                  ),
                                  child: DataTable(
                                    headingRowHeight: 50,
                                    dataRowMinHeight: 60,
                                    dataRowMaxHeight: 60,
                                    headingRowColor: WidgetStateProperty.all(
                                        const Color(0xFF060D1A)),
                                    dataRowColor:
                                        WidgetStateProperty.resolveWith(
                                            (states) => states.contains(
                                                    WidgetState.hovered)
                                                ? const Color(0xFF0D1627)
                                                    .withValues(alpha: 0.8)
                                                : Colors.transparent),
                                    dividerThickness: 0.5,
                                    horizontalMargin: 8,
                                    columnSpacing: 0,
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          "Actions",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: filteredReports.map((report) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.visibility,
                                                    color: Color(0xFF0A84FF),
                                                    size: 19,
                                                  ),
                                                  tooltip: "View Details",
                                                  splashRadius: 18,
                                                  onPressed: () {
                                                    _showReportDetails(
                                                        context, report);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.blue,
                                                    size: 19,
                                                  ),
                                                  tooltip: "Edit Status",
                                                  splashRadius: 18,
                                                  onPressed: () {
                                                    _showEditReportDialog(
                                                        context, report);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.report_gmailerrorred,
                                                    color: Colors.orange,
                                                    size: 19,
                                                  ),
                                                  tooltip: "Mark as Spam",
                                                  splashRadius: 18,
                                                  onPressed: () {
                                                    context
                                                        .read<IncidentBloc>()
                                                        .add(
                                                          UpdateIncidentStatusRequested(
                                                              report.id, 'spam'),
                                                        );
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        backgroundColor:
                                                            const Color(
                                                                0xFF0D1627),
                                                        content: Text(
                                                          "Report #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)} marked as Spam",
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFFFF9500),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  String _formatDateTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? "PM" : "AM";
    final minute = date.minute.toString().padLeft(2, '0');
    return "${date.month}/${date.day}/${date.year} • $hour:$minute $period";
  }

  String _getStatusLabel(String status) {
    switch (
        status.toLowerCase().replaceAll(' ', '').replaceAll('_', '').trim()) {
      case 'pending':
        return 'Pending';
      case 'inprogress':
        return 'In Progress';
      case 'solved':
      case 'resolved':
        return 'Solved';
      case 'spam':
        return 'Spam';
      case 'archived':
        return 'Archived';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(String status) {
    switch (
        status.toLowerCase().replaceAll(' ', '').replaceAll('_', '').trim()) {
      case 'pending':
        return const Color(0xFFFFCC00);
      case 'inprogress':
        return const Color(0xFF0A84FF);
      case 'solved':
      case 'resolved':
        return const Color(0xFF30D158);
      case 'spam':
        return const Color(0xFFFF3B30);
      case 'archived':
        return const Color(0xFF8E8E93);
      default:
        return const Color(0xFF7B8DB0);
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toUpperCase().trim()) {
      case 'CRITICAL':
        return const Color(0xFFFF3B30); // Crimson Red
      case 'HIGH':
        return const Color(0xFFFF9500); // Amber Orange
      case 'MEDIUM':
        return const Color(0xFF00E5FF); // Electric Cyan
      case 'LOW':
        return const Color(0xFF8E8E93); // Slate Gray
      default:
        return const Color(0xFF7B8DB0);
    }
  }

  Widget _buildSortChip({
    required String key,
    required String label,
    required IconData icon,
    Color? activeColor,
  }) {
    final isSelected = sortBy == key && _sortColumnIndex == null;
    final color = activeColor ?? const Color(0xFF0A84FF);
    return InkWell(
      onTap: () {
        setState(() {
          sortBy = key;
          _sortColumnIndex = null;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.16)
              : const Color(0xFF0D1627),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF1E2D4A),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isSelected ? color : const Color(0xFF7B8DB0)),
            SizedBox(width: 6),
            Text(
              label,
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

  void _showEditReportDialog(BuildContext context, IncidentEntity report) {
    String selectedStatus = _getStatusLabel(report.status);
    final TextEditingController notesController =
        TextEditingController(text: report.dispatcherNotes ?? "");
    final TextEditingController etaController =
        TextEditingController(text: report.estimatedResponseTime ?? "");

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1627),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFF1E2D4A))),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.edit_note,
                        color: Color(0xFF0A84FF), size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Dispatch Actions • #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "RESOLUTION STAGE",
                        style: TextStyle(
                            color: Color(0xFF7B8DB0),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        dropdownColor: const Color(0xFF0D1627),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF060D1A),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFF1E2D4A))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFF1E2D4A))),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: "Pending",
                              child: Text("Pending (Awaiting Review)")),
                          DropdownMenuItem(
                              value: "In Progress",
                              child: Text("In Progress (Unit Dispatched)")),
                          DropdownMenuItem(
                              value: "Solved",
                              child: Text("Solved (Incident Resolved)")),
                          DropdownMenuItem(
                              value: "Spam", child: Text("Spam / False Alarm")),
                          DropdownMenuItem(
                              value: "Archived",
                              child: Text("Archived / Closed")),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedStatus = value;
                            });
                          }
                        },
                      ),
                      if (selectedStatus == "In Progress") ...[
                        SizedBox(height: 18),
                        Row(
                          children: [
                            Text(
                              "ESTIMATED TIME OF ARRIVAL (ETA)",
                              style: TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "CITIZEN VISIBLE",
                                style: TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            "5-10 mins",
                            "10-15 mins",
                            "15-20 mins",
                            "20-30 mins",
                            "30-45 mins",
                          ].map((chip) {
                            final isSelected = etaController.text == chip;
                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  etaController.text = chip;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF00E5FF)
                                          .withValues(alpha: 0.25)
                                      : const Color(0xFF060D1A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF00E5FF)
                                        : const Color(0xFF1E2D4A),
                                  ),
                                ),
                                child: Text(
                                  chip,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF00E5FF)
                                        : const Color(0xFF7B8DB0),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: etaController,
                          style: const TextStyle(
                              color: Color(0xFFE8F0FE), fontSize: 13),
                          decoration: InputDecoration(
                            hintText:
                                "Or type custom ETA (e.g. 8 mins, On scene)...",
                            hintStyle: const TextStyle(
                                color: Color(0xFF4A5568), fontSize: 12),
                            prefixIcon: Icon(Icons.timer_outlined,
                                color: Color(0xFF00E5FF), size: 18),
                            filled: true,
                            fillColor: const Color(0xFF060D1A),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: Color(0xFF1E2D4A))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: Color(0xFF1E2D4A))),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: Color(0xFF00E5FF))),
                          ),
                        ),
                      ],
                      SizedBox(height: 18),
                      Text(
                        "DISPATCHER & OPERATIONAL NOTES",
                        style: TextStyle(
                            color: Color(0xFF7B8DB0),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: notesController,
                        maxLines: 4,
                        style: const TextStyle(
                            color: Color(0xFFE8F0FE), fontSize: 13),
                        decoration: InputDecoration(
                          hintText:
                              "Log responder dispatch units, field actions, or resident advisory...",
                          hintStyle: const TextStyle(
                              color: Color(0xFF4A5568), fontSize: 12),
                          filled: true,
                          fillColor: const Color(0xFF060D1A),
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFF1E2D4A))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFF1E2D4A))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFF0A84FF))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text("Cancel",
                      style: TextStyle(color: Color(0xFF7B8DB0))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final notes = notesController.text.trim();
                    final eta = etaController.text.trim();
                    final normalizedStatus =
                        IncidentStatusExtension.normalize(selectedStatus);
                    context.read<IncidentBloc>().add(
                          UpdateIncidentStatusRequested(
                            report.id,
                            normalizedStatus,
                            dispatcherNotes: notes.isEmpty ? null : notes,
                            estimatedResponseTime:
                                (normalizedStatus == 'in_progress' && eta.isNotEmpty)
                                    ? eta
                                    : (normalizedStatus == 'resolved' ||
                                            normalizedStatus == 'solved'
                                        ? null
                                        : (eta.isNotEmpty ? eta : null)),
                          ),
                        );
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF0D1627),
                        content: Text(
                          "Incident #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)} status updated to '$selectedStatus'!",
                          style: const TextStyle(
                              color: Color(0xFF30D158),
                              fontWeight: FontWeight.bold),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text("Save & Broadcast Status",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showReportDetails(BuildContext context, IncidentEntity report) {
    final statusColor = _getStatusColor(report.status);
    final statusLabel = _getStatusLabel(report.status);
    final urgency = report.urgencyStatus?.toUpperCase() ?? "PENDING";
    final urgencyColor = _getUrgencyColor(urgency);

    final fullAddress = BarangaySectorHelper.formatReadableAddress(
      resolvedAddress: report.resolvedAddress,
      areaSector: report.areaSector,
      latitude: report.latitude,
      longitude: report.longitude,
    );

    final hasPhoto =
        report.photoUrl != null && report.photoUrl!.trim().isNotEmpty;
    final isRemotePhoto = hasPhoto &&
        (report.photoUrl!.startsWith('http://') ||
            report.photoUrl!.startsWith('https://'));
    final isLocalPhoto = hasPhoto && !isRemotePhoto;

    final hasVideo =
        report.videoUrl != null && report.videoUrl!.trim().isNotEmpty;
    final isRemoteVideo = hasVideo &&
        (report.videoUrl!.startsWith('http://') ||
            report.videoUrl!.startsWith('https://'));
    final isLocalVideo = hasVideo && !isRemoteVideo;
    final hasCoords = report.latitude != 0.0 || report.longitude != 0.0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1627),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF1E2D4A)),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shield_outlined,
                    color: Color(0xFF0A84FF), size: 22),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Incident Dossier #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      _formatDateTime(report.timestamp),
                      style: const TextStyle(
                          color: Color(0xFF7B8DB0), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prominent On-Behalf Alert Callout (if filed for someone else)
                  if (report.isReportingOnBehalf) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9500).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFF9500).withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9500).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.people_alt,
                                color: Color(0xFFFF9500), size: 22),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "REPORTED ON BEHALF (OFF-SITE FILING)",
                                      style: TextStyle(
                                        color: Color(0xFFFF9500),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF9500)
                                            .withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "ACTION REQUIRED",
                                        style: TextStyle(
                                          color: Color(0xFFFF9500),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "On-Scene Victim: ${report.victimName?.isNotEmpty == true ? report.victimName! : 'Unspecified'}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (report.victimPhone != null &&
                                    report.victimPhone!.trim().isNotEmpty) ...[
                                  SizedBox(height: 2),
                                  Text(
                                    "Victim Phone: ${report.victimPhone!}",
                                    style: const TextStyle(
                                      color: Color(0xFF00E5FF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (report.victimPhone != null &&
                              report.victimPhone!.trim().isNotEmpty)
                            IconButton(
                              onPressed: () async {
                                final uri = Uri.parse(
                                    "tel:${report.victimPhone!.replaceAll(' ', '').trim()}");
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              icon: Icon(Icons.phone_in_talk,
                                  color: Color(0xFF00E5FF), size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF)
                                    .withValues(alpha: 0.15),
                              ),
                              tooltip: "Call Victim Directly",
                            ),
                        ],
                      ),
                    ),
                  ],

                  // Urgency & Category Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF060D1A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1E2D4A)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "CATEGORY",
                                style: TextStyle(
                                  color: Color(0xFF7B8DB0),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                report.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 32,
                          width: 1,
                          color: const Color(0xFF1E2D4A),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "TRIAGE URGENCY LEVEL",
                                style: TextStyle(
                                  color: Color(0xFF7B8DB0),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: urgencyColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    urgency,
                                    style: TextStyle(
                                      color: urgencyColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 32,
                          width: 1,
                          color: const Color(0xFF1E2D4A),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "COMMUNITY CONFIRMED",
                              style: TextStyle(
                                color: Color(0xFF7B8DB0),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "${report.upvoteCount} citizen${report.upvoteCount == 1 ? '' : 's'}",
                              style: const TextStyle(
                                color: Color(0xFF30D158),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        if (report.estimatedResponseTime != null &&
                            report.estimatedResponseTime!.isNotEmpty) ...[
                          Container(
                            height: 32,
                            width: 1,
                            color: const Color(0xFF1E2D4A),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "DISPATCH ETA",
                                style: TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.timer_outlined,
                                      size: 13, color: Color(0xFF00E5FF)),
                                  SizedBox(width: 4),
                                  Text(
                                    report.estimatedResponseTime!,
                                    style: const TextStyle(
                                      color: Color(0xFF00E5FF),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Reporter Identity Box
                  _buildSectionHeader(
                      Icons.person_pin, "REPORTER IDENTITY (LGU COMMAND VIEW)"),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF060D1A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: report.isAnonymous
                            ? const Color(0xFFFF9500).withValues(alpha: 0.4)
                            : const Color(0xFF1E2D4A),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF1E2D4A),
                              child: Text(
                                (report.reporterName != null &&
                                        report.reporterName!.isNotEmpty)
                                    ? report.reporterName![0].toUpperCase()
                                    : "R",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (report.reporterName != null &&
                                            report.reporterName!.isNotEmpty)
                                        ? report.reporterName!
                                        : "Verified Resident",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (report.reporterEmail != null &&
                                      report.reporterEmail!.isNotEmpty)
                                    Text(
                                      report.reporterEmail!,
                                      style: const TextStyle(
                                          color: Color(0xFF7B8DB0),
                                          fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                            if (report.isAnonymous)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9500)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFFF9500)
                                          .withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_outline,
                                        size: 12, color: Color(0xFFFF9500)),
                                    SizedBox(width: 4),
                                    Text(
                                      "Anonymous to Public",
                                      style: TextStyle(
                                        color: Color(0xFFFF9500),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (report.isAnonymous) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9500)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 14, color: Color(0xFFFF9500)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Citizen requested public anonymity. Identity is only visible to Command Center Dispatchers for verification and emergency response.",
                                    style: TextStyle(
                                        color: Color(0xFFFFB340), fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 6),
                        Text(
                          "Account UID: ${report.reporterId}",
                          style: const TextStyle(
                              color: Color(0xFF4A5568),
                              fontSize: 10,
                              fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),

                  if (report.isReportingOnBehalf) ...[
                    SizedBox(height: 16),
                    _buildSectionHeader(Icons.people_alt,
                        "ON-SCENE AFFECTED PERSON (REPORTED ON BEHALF)"),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9500).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFFF9500).withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_pin_circle,
                                  color: Color(0xFFFF9500), size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  report.victimName?.isNotEmpty == true
                                      ? report.victimName!
                                      : "Unspecified Name",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9500).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "OFF-SITE FILING",
                                  style: TextStyle(
                                    color: Color(0xFFFF9500),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (report.victimPhone != null &&
                              report.victimPhone!.trim().isNotEmpty) ...[
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.phone,
                                        color: Color(0xFF00E5FF), size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      "Contact: ${report.victimPhone!}",
                                      style: const TextStyle(
                                        color: Color(0xFF00E5FF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () async {
                                    final uri = Uri.parse(
                                        "tel:${report.victimPhone!.replaceAll(' ', '').trim()}");
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: const Color(0xFF00E5FF)
                                              .withValues(alpha: 0.4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.phone_in_talk,
                                            color: Color(0xFF00E5FF), size: 12),
                                        SizedBox(width: 4),
                                        Text(
                                          "Call Victim",
                                          style: TextStyle(
                                            color: Color(0xFF00E5FF),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 16),

                  // Location Information Box
                  _buildSectionHeader(Icons.location_on,
                      "GEOLOCATION & REVERSE-GEOCODED STREET"),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF060D1A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1E2D4A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.place,
                                color: Color(0xFF0A84FF), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fullAddress,
                                style: const TextStyle(
                                  color: Color(0xFFE8F0FE),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (hasCoords) ...[
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "GPS: ${report.latitude.toStringAsFixed(6)}, ${report.longitude.toStringAsFixed(6)}",
                                style: const TextStyle(
                                  color: Color(0xFF7B8DB0),
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E2D4A),
                                  foregroundColor: const Color(0xFF0A84FF),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: Icon(Icons.map, size: 14),
                                label: Text("Open in Google Maps",
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  launchUrl(
                                    Uri.parse(
                                        "https://www.google.com/maps/search/?api=1&query=${report.latitude},${report.longitude}"),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Description
                  _buildSectionHeader(
                      Icons.description, "INCIDENT DESCRIPTION"),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF060D1A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1E2D4A)),
                    ),
                    child: Text(
                      report.description.isNotEmpty
                          ? report.description
                          : "No description provided.",
                      style: const TextStyle(
                          color: Color(0xFFE8F0FE), fontSize: 13, height: 1.4),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Multimedia Evidence (Photo & Video)
                  _buildSectionHeader(Icons.perm_media, "MULTIMEDIA EVIDENCE"),
                  SizedBox(height: 8),
                  if (!hasPhoto && !hasVideo)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF060D1A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E2D4A)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.attachment,
                              color: Color(0xFF4A5568), size: 16),
                          SizedBox(width: 10),
                          Text(
                            "No photo or video attachments submitted.",
                            style: TextStyle(
                                color: Color(0xFF7B8DB0), fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                  // Photo preview
                  if (isRemotePhoto) ...[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF060D1A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E2D4A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              InAppImageViewerDialog.show(
                                context,
                                imageUrl: report.photoUrl!,
                                title: "Photo Evidence • Incident #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)}",
                              );
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Tooltip(
                                message: "Click to open full resolution viewer",
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14)),
                                  child: Image.network(
                                    report.photoUrl!,
                                    height: 220,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 220,
                                        color: const Color(0xFF060D1A),
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      height: 140,
                                      color: const Color(0xFF060D1A),
                                      padding: const EdgeInsets.all(12),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image_outlined,
                                                color: Color(0xFF7B8DB0), size: 32),
                                            SizedBox(height: 6),
                                            Text(
                                              "Image preview blocked by browser security.",
                                              style: TextStyle(
                                                  color: Color(0xFF7B8DB0),
                                                  fontSize: 11),
                                            ),
                                            SizedBox(height: 6),
                                            TextButton.icon(
                                              icon: Icon(Icons.open_in_new, size: 14),
                                              label: Text("Open in Cloud Viewer",
                                                  style: TextStyle(fontSize: 11)),
                                              onPressed: () => launchUrl(
                                                  Uri.parse(report.photoUrl!),
                                                  mode: LaunchMode.externalApplication),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Citizen Attached Photo",
                                    style: TextStyle(
                                        color: Color(0xFF7B8DB0), fontSize: 12)),
                                TextButton.icon(
                                  icon: Icon(Icons.fullscreen_rounded, size: 16),
                                  label: Text("View Full Resolution",
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    InAppImageViewerDialog.show(
                                      context,
                                      imageUrl: report.photoUrl!,
                                      title: "Photo Evidence • Incident #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)}",
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                  ] else if (isLocalPhoto) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF060D1A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFFF9500)
                                .withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9500)
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.phonelink_erase_rounded,
                                color: Color(0xFFFF9500), size: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Evidence Stored Locally on Citizen Device",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "This report was saved while the citizen was offline or before cloud upload finished. The photo was cached on the reporting phone.",
                                  style: TextStyle(
                                    color: Color(0xFF7B8DB0),
                                    fontSize: 11.5,
                                    height: 1.35,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Path: ${report.photoUrl}",
                                  style: const TextStyle(
                                    color: Color(0xFF4A5568),
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                  ],

                  // Video preview / action
                  if (isRemoteVideo) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF060D1A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF0A84FF)
                                .withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A84FF)
                                  .withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.videocam,
                                color: Color(0xFF0A84FF), size: 24),
                          ),
                          SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Video Evidence Attached",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "High-definition video recording captured at scene",
                                  style: TextStyle(
                                      color: Color(0xFF7B8DB0), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0A84FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: Icon(Icons.play_circle_fill_rounded, size: 18),
                                label: Text("Play In-App",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () {
                                  InAppEvidencePlayerDialog.show(
                                    context,
                                    videoUrl: report.videoUrl!,
                                    title: "Video Evidence • Incident #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)}",
                                  );
                                },
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.open_in_new_rounded,
                                    color: Color(0xFF7B8DB0), size: 18),
                                tooltip: "Open in External Tab",
                                onPressed: () => launchUrl(
                                    Uri.parse(InAppEvidencePlayerDialog.formatPlayableVideoUrl(report.videoUrl!)),
                                    mode: LaunchMode.externalApplication),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                  ] else if (isLocalVideo) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF060D1A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFFF9500)
                                .withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.videocam_off_rounded,
                              color: Color(0xFFFF9500), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Video evidence was cached locally on citizen device and not uploaded to cloud.",
                              style: TextStyle(
                                  color: Color(0xFF7B8DB0), fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                  ],

                  // Dispatcher Notes
                  if (report.dispatcherNotes != null &&
                      report.dispatcherNotes!.isNotEmpty) ...[
                    SizedBox(height: 8),
                    _buildSectionHeader(
                        Icons.speaker_notes, "DISPATCHER & OPERATIONAL LOGS"),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF0A84FF).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF0A84FF)
                                .withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        report.dispatcherNotes!,
                        style: const TextStyle(
                            color: Color(0xFFE8F0FE), height: 1.4, fontSize: 13),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Close",
                  style: TextStyle(color: Color(0xFF7B8DB0))),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A84FF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: Icon(Icons.edit, size: 16),
              label: Text("Update Status / Notes",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(dialogContext);
                _showEditReportDialog(context, report);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF7B8DB0)),
        SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF7B8DB0),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
