import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import '../services/admin_data_service.dart';
import '../constants/admin_colors.dart';
import '../../widgets/custom_3d_card.dart';

class IncidentReportsPage extends StatefulWidget {
  final void Function(double lat, double lng)? onNavigateToMap;

  const IncidentReportsPage({
    super.key,
    this.onNavigateToMap,
  });

  @override
  State<IncidentReportsPage> createState() => _IncidentReportsPageState();
}

class _IncidentReportsPageState extends State<IncidentReportsPage> {
  final dataService = AdminDataService();

  String searchQuery = "";
  String statusFilter = "All";
  String categoryFilter = "All Categories";
  String dateFilter = "All Dates";

  final List<String> _categoryOptions = [
    "All Categories",
    "Fire Incident",
    "Theft / Robbery",
    "Medical Emergency",
    "Violence / Physical Fight",
    "Road Accident",
    "Suspicious Activity",
    "Flood / Calamity",
    "Lost Item / Missing Person",
    "Noise Complaint",
    "Other Emergency",
  ];

  final List<String> _dateOptions = [
    "All Dates",
    "Today",
    "Past 7 Days",
    "Past 30 Days",
  ];

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
      case 'severe':
        return const Color(0xFFFF334B);
      case 'high':
        return const Color(0xFFFF9800);
      case 'medium':
      case 'moderate':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF0088FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final filteredReports = dataService.reports.where((report) {
          final matchesSearch =
              report.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
              report.incidentType.toLowerCase().contains(searchQuery.toLowerCase()) ||
              report.reporterName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              report.location.toLowerCase().contains(searchQuery.toLowerCase());

          final matchesStatus = statusFilter == "All" || report.statusLabel == statusFilter;

          final matchesCategory = categoryFilter == "All Categories" ||
              report.incidentType.toLowerCase() == categoryFilter.toLowerCase();

          final now = DateTime.now();
          final matchesDate = () {
            if (dateFilter == "Today") {
              return report.date.year == now.year &&
                  report.date.month == now.month &&
                  report.date.day == now.day;
            } else if (dateFilter == "Past 7 Days") {
              return report.date.isAfter(now.subtract(const Duration(days: 7)));
            } else if (dateFilter == "Past 30 Days") {
              return report.date.isAfter(now.subtract(const Duration(days: 30)));
            }
            return true;
          }();

          return matchesSearch && matchesStatus && matchesCategory && matchesDate;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & Archive Mode Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Incident Reports",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE8F0FE),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Showing ${filteredReports.length} of ${dataService.reports.length} ${dataService.showArchivedReports ? 'archived' : 'active'} reports",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7B8DB0),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        dataService.showArchivedReports ? "Archived View" : "Active View",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: dataService.showArchivedReports
                              ? const Color(0xFFFF9800)
                              : const Color(0xFF0A84FF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: dataService.showArchivedReports,
                        activeTrackColor: const Color(0xFFFF9800),
                        activeThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFF1E2D4A),
                        onChanged: (val) => dataService.toggleArchivedReports(),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Filter Controls Toolbar Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1627),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2D4A)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search Bar Field
                    TextField(
                      style: const TextStyle(color: Color(0xFFE8F0FE), fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Search by ID, type, reporter, location...",
                        hintStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 12.5),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF7B8DB0), size: 20),
                        filled: true,
                        fillColor: const Color(0xFF0A1424),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 2),
                        ),
                      ),
                      onChanged: (value) => setState(() => searchQuery = value),
                    ),

                    const SizedBox(height: 14),

                    // Dropdown Filter Toolbar Row
                    Wrap(
                      spacing: 14,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Status Filter
                        _buildFilterDropdown<String>(
                          label: "Status",
                          icon: Icons.filter_alt_outlined,
                          value: statusFilter,
                          items: const [
                            DropdownMenuItem(value: "All", child: Text("All Statuses")),
                            DropdownMenuItem(value: "Pending", child: Text("Pending")),
                            DropdownMenuItem(value: "In Progress", child: Text("In Progress")),
                            DropdownMenuItem(value: "Solved", child: Text("Solved")),
                            DropdownMenuItem(value: "Spam", child: Text("Spam")),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => statusFilter = val);
                            }
                          },
                        ),

                        // Category Filter
                        _buildFilterDropdown<String>(
                          label: "Category",
                          icon: Icons.category_outlined,
                          value: categoryFilter,
                          items: _categoryOptions.map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => categoryFilter = val);
                            }
                          },
                        ),

                        // Date Filter
                        _buildFilterDropdown<String>(
                          label: "Date",
                          icon: Icons.calendar_today_outlined,
                          value: dateFilter,
                          items: _dateOptions.map((opt) {
                            return DropdownMenuItem(value: opt, child: Text(opt));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => dateFilter = val);
                            }
                          },
                        ),

                        // Reset Filters Button
                        if (statusFilter != "All" || categoryFilter != "All Categories" || dateFilter != "All Dates" || searchQuery.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                searchQuery = "";
                                statusFilter = "All";
                                categoryFilter = "All Categories";
                                dateFilter = "All Dates";
                              });
                            },
                            icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF0A84FF)),
                            label: const Text(
                              "Reset Filters",
                              style: TextStyle(color: Color(0xFF0A84FF), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Data Table Container
              Expanded(
                child: Custom3dCard(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 22,
                  child: filteredReports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inbox_outlined, color: Color(0xFF2A3F60), size: 56),
                              const SizedBox(height: 14),
                              const Text(
                                "No incident reports match your criteria",
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
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowHeight: 50,
                              headingRowColor: WidgetStateProperty.all(const Color(0xFF060D1A)),
                              dataRowColor: WidgetStateProperty.resolveWith(
                                (states) => states.contains(WidgetState.hovered)
                                    ? const Color(0xFF0D1627).withValues(alpha: 0.8)
                                    : Colors.transparent,
                              ),
                              dividerThickness: 0.5,
                              columns: const [
                                DataColumn(
                                  label: Text("Report ID", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7B8DB0), fontSize: 12)),
                                ),
                                DataColumn(
                                  label: Text("Type / Category", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7B8DB0), fontSize: 12)),
                                ),
                                DataColumn(
                                  label: Text("Urgency", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7B8DB0), fontSize: 12)),
                                ),
                                DataColumn(
                                  label: Text("Reporter", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7B8DB0), fontSize: 12)),
                                ),
                                DataColumn(
                                  label: Text("Location", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7B8DB0), fontSize: 12)),
                                ),
                                DataColumn(
                                  label: Text("Date & Time", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7B8DB0), fontSize: 12)),
                                ),
                                DataColumn(
                                  label: Text("Status", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7B8DB0), fontSize: 12)),
                                ),
                                DataColumn(
                                  label: Text("Actions", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7B8DB0), fontSize: 12)),
                                ),
                              ],
                              rows: filteredReports.map((report) {
                                final urgencyColor = _getUrgencyColor(report.urgencyLevel);
                                final hasCoords = report.latitude != null && report.longitude != null;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(
                                      report.id,
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE8F0FE), fontSize: 12),
                                    )),
                                    DataCell(Text(
                                      report.incidentType,
                                      style: const TextStyle(color: Color(0xFFE8F0FE), fontSize: 12),
                                    )),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: urgencyColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: urgencyColor.withValues(alpha: 0.35)),
                                        ),
                                        child: Text(
                                          report.urgencyLevel,
                                          style: TextStyle(color: urgencyColor, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(
                                      report.reporterName,
                                      style: const TextStyle(color: Color(0xFFE8F0FE), fontSize: 12),
                                    )),
                                    DataCell(Text(
                                      report.location,
                                      style: const TextStyle(color: Color(0xFF7B8DB0), fontSize: 12),
                                    )),
                                    DataCell(Text(
                                      _formatDate(report.date),
                                      style: const TextStyle(color: Color(0xFF7B8DB0), fontSize: 12),
                                    )),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: report.statusColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: report.statusColor.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          report.statusLabel,
                                          style: TextStyle(
                                            color: report.statusColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility, color: AdminColors.primaryRose, size: 20),
                                            tooltip: "View Details",
                                            onPressed: () => _showReportDetails(context, report),
                                          ),
                                          if (hasCoords)
                                            IconButton(
                                              icon: const Icon(Icons.map_outlined, color: Color(0xFF00E5FF), size: 20),
                                              tooltip: "View on Map",
                                              onPressed: () {
                                                if (widget.onNavigateToMap != null) {
                                                  widget.onNavigateToMap!(report.latitude!, report.longitude!);
                                                }
                                              },
                                            ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                            tooltip: "Edit Status",
                                            onPressed: () => _showEditReportDialog(context, report),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.report_gmailerrorred, color: Colors.orange, size: 20),
                                            tooltip: "Mark as Spam",
                                            onPressed: () {
                                              dataService.markReportAsSpam(report.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("Report ${report.id} marked as Spam"),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.archive, color: Colors.redAccent, size: 20),
                                            tooltip: "Archive Report",
                                            onPressed: () => _confirmArchiveReport(context, report),
                                          ),
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1424),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2D4A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF0A84FF), size: 16),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: const TextStyle(color: Color(0xFF7B8DB0), fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              dropdownColor: const Color(0xFF0D1627),
              style: const TextStyle(color: Color(0xFFE8F0FE), fontSize: 12, fontWeight: FontWeight.bold),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0A84FF), size: 18),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return "Not recorded";
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "${date.month}/${date.day}/${date.year}, $hour:$minute";
  }

  void _confirmArchiveReport(BuildContext context, IncidentReport report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1627),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E2D4A)),
        ),
        title: Row(
          children: [
            const Icon(Icons.archive_outlined, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text(
              "Archive Report ${report.id}",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to archive this incident report? It will be safely stored in the database archive and hidden from normal active views.",
          style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF8E9BAE))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              dataService.archiveReport(report.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Report ${report.id} archived successfully"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Archive Report"),
          ),
        ],
      ),
    );
  }

  void _showEditReportDialog(BuildContext context, IncidentReport report) {
    IncidentStatus selectedStatus = report.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1627),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF1E2D4A)),
              ),
              title: Text(
                "Update Status: ${report.id}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 400,
                child: DropdownButtonFormField<IncidentStatus>(
                  initialValue: selectedStatus,
                  dropdownColor: const Color(0xFF0D1627),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: "Status",
                    labelStyle: const TextStyle(color: Color(0xFF7B8DB0)),
                    filled: true,
                    fillColor: const Color(0xFF0A1424),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: const [
                    DropdownMenuItem(value: IncidentStatus.pending, child: Text("Pending")),
                    DropdownMenuItem(value: IncidentStatus.inProgress, child: Text("In Progress")),
                    DropdownMenuItem(value: IncidentStatus.solved, child: Text("Solved")),
                    DropdownMenuItem(value: IncidentStatus.spam, child: Text("Spam")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Color(0xFF7B8DB0))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    dataService.updateReportStatus(report.id, selectedStatus);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Report status updated successfully"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text("Save Status"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showReportDetails(BuildContext context, IncidentReport report) {
    final submittedAt = dataService.getStatusTimestamp(report.id, IncidentStatus.pending) ?? report.date;
    final inProgressAt = dataService.getStatusTimestamp(report.id, IncidentStatus.inProgress);
    final solvedAt = dataService.getStatusTimestamp(report.id, IncidentStatus.solved);

    final isInProgressActive = report.status == IncidentStatus.inProgress || report.status == IncidentStatus.solved;
    final isSolvedActive = report.status == IncidentStatus.solved;
    final hasCoords = report.latitude != null && report.longitude != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1627),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFF1E2D4A)),
          ),
          title: Row(
            children: [
              Text(
                "Incident Details - ${report.id}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: report.statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: report.statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  report.statusLabel,
                  style: TextStyle(color: report.statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF060D1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E2D4A)),
                    ),
                    child: Column(
                      children: [
                        _detailRow("Incident Type", report.incidentType),
                        const Divider(color: Color(0xFF1E2D4A), height: 16),
                        _detailRow("Urgency Level", report.urgencyLevel),
                        const Divider(color: Color(0xFF1E2D4A), height: 16),
                        _detailRow("Reporter Name", report.reporterName),
                        const Divider(color: Color(0xFF1E2D4A), height: 16),
                        _detailRow("Incident Location", report.location),
                        if (hasCoords) ...[
                          const Divider(color: Color(0xFF1E2D4A), height: 16),
                          _detailRow(
                            "GPS Coordinates",
                            "${report.latitude!.toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}",
                          ),
                        ],
                        const Divider(color: Color(0xFF1E2D4A), height: 16),
                        _detailRow("Reported Time", _formatDateTime(report.date)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Description",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.description,
                    style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 13, height: 1.4),
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    "Status Timeline",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  _timelineTile(
                    icon: Icons.access_time,
                    title: "Pending",
                    subtitle: "Submitted: ${_formatDateTime(submittedAt)}",
                    active: true,
                  ),
                  _timelineLine(),
                  _timelineTile(
                    icon: Icons.build,
                    title: "In Progress",
                    subtitle: "Dispatched: ${_formatDateTime(inProgressAt)}",
                    active: isInProgressActive,
                  ),
                  _timelineLine(),
                  _timelineTile(
                    icon: Icons.check_circle,
                    title: "Solved",
                    subtitle: "Solved: ${_formatDateTime(solvedAt)}",
                    active: isSolvedActive,
                  ),
                  if (report.status == IncidentStatus.spam) ...[
                    _timelineLine(),
                    _timelineTile(
                      icon: Icons.report_gmailerrorred,
                      title: "Spam",
                      subtitle: "Marked as Spam",
                      active: true,
                      activeColor: Colors.redAccent,
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            if (hasCoords)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  foregroundColor: const Color(0xFF00E5FF),
                  side: const BorderSide(color: Color(0xFF00E5FF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text("View on Command Map"),
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.onNavigateToMap != null) {
                    widget.onNavigateToMap!(report.latitude!, report.longitude!);
                  }
                },
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Color(0xFF7B8DB0))),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            "$label:",
            style: const TextStyle(color: Color(0xFF7B8DB0), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _timelineLine() {
    return Container(
      margin: const EdgeInsets.only(left: 15),
      width: 2,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D4A),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _timelineTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool active,
    Color activeColor = const Color(0xFF0A84FF),
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? activeColor : const Color(0xFF1E2D4A),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.white : const Color(0xFF7B8DB0),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: active ? const Color(0xFF8E9BAE) : const Color(0xFF4A5568),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
