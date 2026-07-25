import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import '../services/admin_data_service.dart';
import '../constants/admin_colors.dart';
import '../../widgets/custom_3d_card.dart';

class IncidentReportsPage extends StatefulWidget {
  const IncidentReportsPage({super.key});

  @override
  State<IncidentReportsPage> createState() => _IncidentReportsPageState();
}

class _IncidentReportsPageState extends State<IncidentReportsPage> {
  final dataService = AdminDataService();

  String searchQuery = "";
  String statusFilter = "All";

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final filteredReports = dataService.reports.where((report) {
          final matchesSearch =
              report.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
              report.incidentType.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              report.reporterName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              report.location.toLowerCase().contains(searchQuery.toLowerCase());

          final matchesStatus =
              statusFilter == "All" || report.statusLabel == statusFilter;

          return matchesSearch && matchesStatus;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Incident Reports",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE8F0FE)),
                  ),
                  Row(
                    children: [
                      Text(
                        dataService.showArchivedReports
                            ? "Archived"
                            : "Active",
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Color(0xFF7B8DB0)),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: dataService.showArchivedReports,
                        activeTrackColor: const Color(0xFF0A84FF),
                        activeColor: Colors.white,
                        onChanged: (val) => dataService.toggleArchivedReports(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1627),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: const Color(0xFF1E2D4A)),
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
                          hintText:
                              "Search by ID, type, reporter, location...",
                          hintStyle: const TextStyle(
                              color: Color(0xFF4A5568), fontSize: 12.5),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFF7B8DB0), size: 20),
                          filled: true,
                          fillColor: const Color(0xFF0D1627),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: Color(0xFF1E2D4A)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: Color(0xFF1E2D4A)),
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
                  const SizedBox(width: 16),
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
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF0A84FF)),
                        items: const [
                          DropdownMenuItem(
                              value: "All",
                              child: Text("All Statuses")),
                          DropdownMenuItem(
                              value: "Pending",
                              child: Text("Pending")),
                          DropdownMenuItem(
                              value: "In Progress",
                              child: Text("In Progress")),
                          DropdownMenuItem(
                              value: "Solved", child: Text("Solved")),
                          DropdownMenuItem(
                              value: "Spam", child: Text("Spam")),
                        ],
                        onChanged: (value) {
                          if (value != null)
                            setState(() => statusFilter = value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Custom3dCard(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 22,
                  child: filteredReports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  color: const Color(0xFF2A3F60), size: 56),
                              const SizedBox(height: 14),
                              const Text(
                                "No incident reports found",
                                style: TextStyle(
                                    color: Color(0xFF7B8DB0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
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
                              headingRowColor: WidgetStateProperty.all(
                                  const Color(0xFF060D1A)),
                              dataRowColor: WidgetStateProperty.resolveWith(
                                  (states) => states
                                          .contains(WidgetState.hovered)
                                      ? const Color(0xFF0D1627)
                                          .withValues(alpha: 0.8)
                                      : Colors.transparent),
                              dividerThickness: 0.5,
                              columns: const [
                                DataColumn(
                                    label: Text("Report ID",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12))),
                                DataColumn(
                                    label: Text("Type",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12))),
                                DataColumn(
                                    label: Text("Urgency",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12))),
                                DataColumn(
                                    label: Text("Reporter",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12))),
                                DataColumn(
                                    label: Text("Location",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12))),
                                DataColumn(
                                    label: Text("Date",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12))),
                                DataColumn(
                                    label: Text("Status",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12))),
                                DataColumn(
                                    label: Text("Actions",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12))),
                              ],
                              rows: filteredReports.map((report) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(report.id,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFE8F0FE),
                                            fontSize: 12))),
                                    DataCell(Text(report.incidentType,
                                        style: const TextStyle(
                                            color: Color(0xFFE8F0FE),
                                            fontSize: 12))),
                                    DataCell(Text(report.urgencyLevel,
                                        style: const TextStyle(
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12))),
                                    DataCell(Text(report.reporterName,
                                        style: const TextStyle(
                                            color: Color(0xFFE8F0FE),
                                            fontSize: 12))),
                                    DataCell(Text(report.location,
                                        style: const TextStyle(
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12))),
                                    DataCell(Text(_formatDate(report.date),
                                        style: const TextStyle(
                                            color: Color(0xFF7B8DB0),
                                            fontSize: 12))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: report.statusColor
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: report.statusColor
                                                  .withValues(alpha: 0.3)),
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
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.visibility,
                                              color: AdminColors.primaryRose,
                                              size: 20,
                                            ),
                                            tooltip: "View Details",
                                            onPressed: () {
                                              _showReportDetails(
                                                context,
                                                report,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            tooltip: "Edit Status",
                                            onPressed: () {
                                              _showEditReportDialog(
                                                context,
                                                report,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.report_gmailerrorred,
                                              color: Colors.orange,
                                              size: 20,
                                            ),
                                            tooltip: "Mark as Spam",
                                            onPressed: () {
                                              dataService.markReportAsSpam(
                                                report.id,
                                              );

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Report ${report.id} marked as Spam",
                                                  ),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.archive,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            tooltip: "Archive Report",
                                            onPressed: () {
                                              dataService.archiveReport(
                                                report.id,
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
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return "Not yet";

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return "${date.month}/${date.day}/${date.year}, $hour:$minute";
  }

  void _showEditReportDialog(BuildContext context, IncidentReport report) {
    IncidentStatus selectedStatus = report.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Update Status: ${report.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 400,
                child: DropdownButtonFormField<IncidentStatus>(
                  initialValue: selectedStatus,
                  decoration: InputDecoration(
                    labelText: "Status",
                    filled: true,
                    fillColor: AdminColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: IncidentStatus.pending,
                      child: Text("Pending"),
                    ),
                    DropdownMenuItem(
                      value: IncidentStatus.inProgress,
                      child: Text("In Progress"),
                    ),
                    DropdownMenuItem(
                      value: IncidentStatus.solved,
                      child: Text("Solved"),
                    ),
                    DropdownMenuItem(
                      value: IncidentStatus.spam,
                      child: Text("Spam"),
                    ),
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryRose,
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
    final submittedAt =
        dataService.getStatusTimestamp(report.id, IncidentStatus.pending) ??
        report.date;

    final inProgressAt = dataService.getStatusTimestamp(
      report.id,
      IncidentStatus.inProgress,
    );

    final solvedAt = dataService.getStatusTimestamp(
      report.id,
      IncidentStatus.solved,
    );

    final isInProgressActive =
        report.status == IncidentStatus.inProgress ||
        report.status == IncidentStatus.solved;

    final isSolvedActive = report.status == IncidentStatus.solved;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text("Incident Details - ${report.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow("Incident Type", report.incidentType),
                  _detailRow("Reporter", report.reporterName),
                  _detailRow("Location", report.location),
                  _detailRow("Status", report.statusLabel),
                  const SizedBox(height: 15),
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(report.description),
                  const SizedBox(height: 30),
                  const Text(
                    "Status Timeline",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
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
                      activeColor: Colors.red,
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _timelineLine() {
    return Container(
      margin: const EdgeInsets.only(left: 15),
      width: 2,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _timelineTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool active,
    Color activeColor = AdminColors.primaryRose,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
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
                  color: active ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(color: active ? Colors.black54 : Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
