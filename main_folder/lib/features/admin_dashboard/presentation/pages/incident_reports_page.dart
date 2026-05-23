import 'package:flutter/material.dart';
import '../../data/models/incident_report.dart';
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
        // Filter reports list based on search bar text and status filter dropdown
        final filteredReports = dataService.reports.where((report) {
          final matchesSearch = report.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
              report.reporterName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              report.incidentType.toLowerCase().contains(searchQuery.toLowerCase()) ||
              report.location.toLowerCase().contains(searchQuery.toLowerCase());

          final matchesStatus = statusFilter == "All" || 
              (statusFilter == "Pending" && report.status == IncidentStatus.pending) ||
              (statusFilter == "In Progress" && report.status == IncidentStatus.inProgress) ||
              (statusFilter == "Solved" && report.status == IncidentStatus.solved);

          return matchesSearch && matchesStatus;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and Filter Controls Layout
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    // Search Field
                    Expanded(
                      flex: 4,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search by ID, reporter, type, or location...",
                          prefixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AdminColors.border),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            searchQuery = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Status Filter Dropdown
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: statusFilter,
                        decoration: InputDecoration(
                          labelText: "Filter Status",
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AdminColors.border),
                          ),
                        ),
                        items: ["All", "Pending", "In Progress", "Solved"].map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              statusFilter = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Data Table Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: filteredReports.isEmpty
                        ? const Center(
                            child: Text(
                              "No incident reports found matching search criteria.",
                              style: TextStyle(color: AdminColors.textLight, fontSize: 15),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(AdminColors.primaryGreen.withOpacity(0.05)),
                                columnSpacing: 35,
                                columns: const [
                                  DataColumn(label: Text("Report ID", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Incident Type", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Reporter Name", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Location", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: filteredReports.map((report) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(report.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text(report.incidentType)),
                                      DataCell(Text(report.reporterName)),
                                      DataCell(Text(report.location)),
                                      DataCell(Text("${report.date.day}/${report.date.month}/${report.date.year}")),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: report.statusColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            report.statusLabel,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: report.statusColor == AdminColors.pendingYellow 
                                                  ? Colors.orange.shade800
                                                  : report.statusColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            // View Dialog Trigger
                                            IconButton(
                                              icon: const Icon(Icons.visibility, color: Colors.grey, size: 20),
                                              tooltip: "View Details",
                                              onPressed: () => _showViewDialog(context, report),
                                            ),
                                            // Edit Dialog Trigger
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                              tooltip: "Edit Report",
                                              onPressed: () => _showEditDialog(context, report),
                                            ),
                                            // Delete Trigger
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: AdminColors.dangerRed, size: 20),
                                              tooltip: "Delete Report",
                                              onPressed: () => _confirmDelete(context, report.id),
                                            ),
                                            // Solve Trigger Shortcut
                                            if (report.status != IncidentStatus.solved)
                                              IconButton(
                                                icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                                                tooltip: "Mark as Solved",
                                                onPressed: () {
                                                  dataService.updateReportStatus(report.id, IncidentStatus.solved);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text("Report ${report.id} marked as Solved")),
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
              ),
            ],
          ),
        );
      },
    );
  }

  // View report details dialog popup
  void _showViewDialog(BuildContext context, IncidentReport report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Report Details: ${report.id}"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: report.statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: report.statusColor == AdminColors.pendingYellow 
                        ? Colors.orange.shade800
                        : report.statusColor,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 10),
                _detailField("Incident Type", report.incidentType),
                _detailField("Reporter Name", report.reporterName),
                _detailField("Location", report.location),
                _detailField("Reported Date", "${report.date.day}/${report.date.month}/${report.date.year} ${report.date.hour}:${report.date.minute}"),
                const SizedBox(height: 15),
                const Text(
                  "Incident Description:",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    report.description,
                    style: const TextStyle(fontSize: 13.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _detailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(), // Keep design centered
          SizedBox(
            width: 130,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textLight, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  // Edit details of a report dialog popup
  void _showEditDialog(BuildContext context, IncidentReport report) {
    final formKey = GlobalKey<FormState>();
    final typeController = TextEditingController(text: report.incidentType);
    final locationController = TextEditingController(text: report.location);
    final descController = TextEditingController(text: report.description);
    IncidentStatus selectedStatus = report.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Edit Incident Report: ${report.id}"),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        // Type field
                        TextFormField(
                          controller: typeController,
                          decoration: const InputDecoration(labelText: "Incident Type"),
                          validator: (val) => val == null || val.isEmpty ? "Enter incident type" : null,
                        ),
                        const SizedBox(height: 15),
                        // Location field
                        TextFormField(
                          controller: locationController,
                          decoration: const InputDecoration(labelText: "Location"),
                          validator: (val) => val == null || val.isEmpty ? "Enter location details" : null,
                        ),
                        const SizedBox(height: 15),
                        // Status Field
                        DropdownButtonFormField<IncidentStatus>(
                          value: selectedStatus,
                          decoration: const InputDecoration(labelText: "Report Status"),
                          items: IncidentStatus.values.map((status) {
                            String label = status == IncidentStatus.pending 
                                ? "Pending" 
                                : status == IncidentStatus.inProgress 
                                    ? "In Progress" 
                                    : "Solved";
                            return DropdownMenuItem<IncidentStatus>(
                              value: status,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                  selectedStatus = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        // Description text area
                        TextFormField(
                          controller: descController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: "Incident Description",
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.isEmpty ? "Enter details description" : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primaryGreen, foregroundColor: Colors.white),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updated = report.copyWith(
                        incidentType: typeController.text.trim(),
                        location: locationController.text.trim(),
                        status: selectedStatus,
                        description: descController.text.trim(),
                      );
                      dataService.editReport(updated);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Report details successfully updated")),
                      );
                    }
                  },
                  child: const Text("Save Changes"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Delete incident report confirmation dialog popup
  void _confirmDelete(BuildContext context, String reportId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Report"),
          content: Text("Are you sure you want to permanently delete report $reportId? This action is irreversible."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.dangerRed, foregroundColor: Colors.white),
              onPressed: () {
                dataService.deleteReport(reportId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Report $reportId deleted successfully")),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
