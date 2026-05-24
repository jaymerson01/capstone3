import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import '../services/admin_data_service.dart';
import '../constants/admin_colors.dart';

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
                  report.incidentType
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()) ||
                  report.reporterName
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()) ||
                  report.location
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());

          final matchesStatus =
              statusFilter == "All" || report.statusLabel == statusFilter;

          return matchesSearch && matchesStatus;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Incident Reports",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search reports...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  DropdownButton<String>(
                    value: statusFilter,
                    items: const [
                      DropdownMenuItem(value: "All", child: Text("All")),
                      DropdownMenuItem(value: "Pending", child: Text("Pending")),
                      DropdownMenuItem(
                        value: "In Progress",
                        child: Text("In Progress"),
                      ),
                      DropdownMenuItem(value: "Solved", child: Text("Solved")),
                      DropdownMenuItem(value: "Spam", child: Text("Spam")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          statusFilter = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: filteredReports.isEmpty
                      ? const Center(
                          child: Text("No incident reports found."),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text("Report ID")),
                                DataColumn(label: Text("Type")),
                                DataColumn(label: Text("Reporter")),
                                DataColumn(label: Text("Location")),
                                DataColumn(label: Text("Date")),
                                DataColumn(label: Text("Status")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: filteredReports.map((report) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(report.id)),
                                    DataCell(Text(report.incidentType)),
                                    DataCell(Text(report.reporterName)),
                                    DataCell(Text(report.location)),
                                    DataCell(Text(_formatDate(report.date))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              report.statusColor.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          report.statusLabel,
                                          style: TextStyle(
                                            color: report.statusColor,
                                            fontWeight: FontWeight.bold,
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
                                              color: AdminColors.primaryGreen,
                                              size: 20,
                                            ),
                                            tooltip: "View Details",
                                            onPressed: () {
                                              _showReportDetails(context, report);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            tooltip: "Edit Report",
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
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            tooltip: "Mark as Spam",
                                            onPressed: () {
                                              dataService.markReportAsSpam(
                                                report.id,
                                              );

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Report ${report.id} marked as Spam",
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            tooltip: "Delete Report",
                                            onPressed: () {
                                              dataService.deleteReport(report.id);
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

  void _showEditReportDialog(
    BuildContext context,
    IncidentReport report,
  ) {
    IncidentStatus selectedStatus = report.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Update Report Status: ${report.id}"),
              content: SizedBox(
                width: 400,
                child: DropdownButtonFormField<IncidentStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
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
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    dataService.updateReportStatus(
                      report.id,
                      selectedStatus,
                    );

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Report status updated successfully"),
                      ),
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showReportDetails(
    BuildContext context,
    IncidentReport report,
  ) {
    final submittedAt =
        dataService.getStatusTimestamp(report.id, IncidentStatus.pending) ??
            report.date;

    final inProgressAt =
        dataService.getStatusTimestamp(report.id, IncidentStatus.inProgress);

    final solvedAt =
        dataService.getStatusTimestamp(report.id, IncidentStatus.solved);

    final isInProgressActive = report.status == IncidentStatus.inProgress ||
        report.status == IncidentStatus.solved;

    final isSolvedActive = report.status == IncidentStatus.solved;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Incident Details - ${report.id}"),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
    Color activeColor = AdminColors.primaryGreen,
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
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
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
                style: TextStyle(
                  color: active ? Colors.black54 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}