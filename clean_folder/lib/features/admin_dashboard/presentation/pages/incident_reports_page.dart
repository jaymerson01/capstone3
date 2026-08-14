import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

class IncidentReportsPage extends StatefulWidget {
  const IncidentReportsPage({super.key});

  @override
  State<IncidentReportsPage> createState() => _IncidentReportsPageState();
}

class _IncidentReportsPageState extends State<IncidentReportsPage> {
  String searchQuery = "";
  String statusFilter = "All";
  bool showArchivedReports = false;

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
              const Text(
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
                  const SizedBox(width: 8),
                  Switch(
                    value: showArchivedReports,
                    activeTrackColor: const Color(0xFF0A84FF),
                    activeColor: Colors.white,
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
          const SizedBox(height: 18),
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
                      prefixIcon: const Icon(Icons.search,
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
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<IncidentBloc, IncidentState>(
              builder: (context, state) {
                if (state is IncidentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is IncidentError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is IncidentLoaded) {
                  final filteredReports = state.incidents.where((report) {
                    final matchesSearch = report.id
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        report.category
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        report.reporterId
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        (report.resolvedAddress ?? "")
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase());

                    final reportStatusLabel =
                        _getStatusLabel(report.status);
                    final matchesStatus = statusFilter == "All" ||
                        reportStatusLabel == statusFilter;

                    return matchesSearch && matchesStatus;
                  }).toList();

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
                                const SizedBox(height: 14),
                                const Text(
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
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowHeight: 50,
                                headingRowColor: WidgetStateProperty.all(
                                    const Color(0xFF060D1A)),
                                dataRowColor: WidgetStateProperty.resolveWith(
                                    (states) => states.contains(
                                            WidgetState.hovered)
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
                                      label: Text("Category",
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
                                  final statusColor =
                                      _getStatusColor(report.status);
                                  final statusLabel =
                                      _getStatusLabel(report.status);

                                  return DataRow(
                                    cells: [
                                      DataCell(Text(report.id.substring(0, 8), // shorten ID
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFE8F0FE),
                                              fontSize: 12))),
                                      DataCell(Text(report.category,
                                          style: const TextStyle(
                                              color: Color(0xFFE8F0FE),
                                              fontSize: 12))),
                                      DataCell(Text(
                                          report.urgencyStatus ?? "N/A",
                                          style: const TextStyle(
                                              color: Color(0xFF7B8DB0),
                                              fontSize: 12))),
                                      DataCell(Text(report.reporterId,
                                          style: const TextStyle(
                                              color: Color(0xFFE8F0FE),
                                              fontSize: 12))),
                                      DataCell(Text(
                                          report.resolvedAddress ?? "GPS Only",
                                          style: const TextStyle(
                                              color: Color(0xFF7B8DB0),
                                              fontSize: 12))),
                                      DataCell(Text(
                                          _formatDate(report.timestamp),
                                          style: const TextStyle(
                                              color: Color(0xFF7B8DB0),
                                              fontSize: 12))),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: statusColor
                                                    .withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            statusLabel,
                                            style: TextStyle(
                                              color: statusColor,
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
                                                color: Color(0xFF0A84FF),
                                                size: 20,
                                              ),
                                              tooltip: "View Details",
                                              onPressed: () {
                                                _showReportDetails(
                                                    context, report);
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
                                                    context, report);
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
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Report ${report.id} marked as Spam"),
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

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'inprogress':
      case 'in_progress':
        return 'In Progress';
      case 'solved':
      case 'resolved':
        return 'Solved';
      case 'spam':
        return 'Spam';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFCC00);
      case 'inprogress':
      case 'in_progress':
        return const Color(0xFF0A84FF);
      case 'solved':
      case 'resolved':
        return const Color(0xFF30D158);
      case 'spam':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFF7B8DB0);
    }
  }

  void _showEditReportDialog(BuildContext context, IncidentEntity report) {
    String selectedStatus = _getStatusLabel(report.status);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1627),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFF1E2D4A))),
              title: Text(
                "Update Status: ${report.id.substring(0, 8)}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              content: SizedBox(
                width: 400,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  dropdownColor: const Color(0xFF0D1627),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Status",
                    labelStyle: const TextStyle(color: Color(0xFF7B8DB0)),
                    filled: true,
                    fillColor: const Color(0xFF060D1A),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: "Pending", child: Text("Pending")),
                    DropdownMenuItem(
                        value: "In Progress", child: Text("In Progress")),
                    DropdownMenuItem(
                        value: "Solved", child: Text("Solved")),
                    DropdownMenuItem(value: "Spam", child: Text("Spam")),
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
                  child: const Text("Cancel",
                      style: TextStyle(color: Color(0xFF7B8DB0))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Status updated to $selectedStatus (UI Mock)"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    // TODO: Trigger BLoC event to update status here
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

  void _showReportDetails(BuildContext context, IncidentEntity report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1627),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: Color(0xFF1E2D4A))),
          title: Text(
            "Incident Details - ${report.id.substring(0, 8)}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow("Category", report.category),
                  _detailRow("Reporter", report.reporterId),
                  _detailRow("Location", report.resolvedAddress ?? "Unknown"),
                  _detailRow("Status", _getStatusLabel(report.status)),
                  const SizedBox(height: 15),
                  const Text(
                    "Description",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    report.description,
                    style: const TextStyle(color: Color(0xFF7B8DB0)),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close",
                  style: TextStyle(color: Color(0xFF7B8DB0))),
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
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF7B8DB0)),
            ),
          ),
        ],
      ),
    );
  }
}
