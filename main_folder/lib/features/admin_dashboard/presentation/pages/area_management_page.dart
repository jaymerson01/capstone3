import 'package:flutter/material.dart';
import '../../data/models/area.dart';
import '../services/admin_data_service.dart';
import '../constants/admin_colors.dart';

class AreaManagementPage extends StatefulWidget {
  const AreaManagementPage({super.key});

  @override
  State<AreaManagementPage> createState() => _AreaManagementPageState();
}

class _AreaManagementPageState extends State<AreaManagementPage> {
  final dataService = AdminDataService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header action buttons bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Manage barangays / Areas",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminColors.textDark),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Monitor incidents count and edit safety watch regions.",
                        style: TextStyle(fontSize: 13, color: AdminColors.textLight),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _showAddAreaDialog(context),
                    icon: const Icon(Icons.add_road, size: 18),
                    label: const Text("Add New Area", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Areas list layout
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
                    child: dataService.areas.isEmpty
                        ? const Center(
                            child: Text(
                              "No tracking areas defined yet.",
                              style: TextStyle(color: AdminColors.textLight, fontSize: 15),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(AdminColors.primaryGreen.withOpacity(0.05)),
                                columnSpacing: 60,
                                columns: const [
                                  DataColumn(label: Text("Area ID", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Area/Barangay Name", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Recorded Incidents Count", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Risk Status", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: dataService.areas.map((area) {
                                  // Determine status badge based on incident counts
                                  String riskLevel = "Low Risk";
                                  Color riskColor = AdminColors.solvedGreen;
                                  if (area.incidentsCount > 300) {
                                    riskLevel = "High Risk";
                                    riskColor = AdminColors.dangerRed;
                                  } else if (area.incidentsCount > 100) {
                                    riskLevel = "Medium Risk";
                                    riskColor = AdminColors.pendingYellow;
                                  }

                                  return DataRow(
                                    cells: [
                                      DataCell(Text(area.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text(area.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text(area.incidentsCount.toString())),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: riskColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            riskLevel,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: riskColor == AdminColors.pendingYellow 
                                                  ? Colors.orange.shade800
                                                  : riskColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            // Edit dialog trigger
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                              tooltip: "Rename Area",
                                              onPressed: () => _showEditAreaDialog(context, area),
                                            ),
                                            // Delete trigger
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: AdminColors.dangerRed, size: 20),
                                              tooltip: "Delete Area",
                                              onPressed: () => _confirmDeleteArea(context, area),
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

  // Add Area popup dialog
  void _showAddAreaDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final incidentsController = TextEditingController(text: "0");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Register Watch Area"),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Area / Barangay Name",
                      hintText: "e.g. Barangay San Dionisio",
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? "Enter area name" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: incidentsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Initial Incident Count (Mock data only)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Enter initial incident count";
                      if (int.tryParse(val) == null) return "Enter a valid integer number";
                      return null;
                    },
                  ),
                ],
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
                  final newArea = AreaInfo(
                    id: "AREA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                    name: nameController.text.trim(),
                    incidentsCount: int.parse(incidentsController.text),
                  );
                  dataService.addArea(newArea);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Area '${newArea.name}' registered successfully")),
                  );
                }
              },
              child: const Text("Register Area"),
            ),
          ],
        );
      },
    );
  }

  // Edit Area popup dialog
  void _showEditAreaDialog(BuildContext context, AreaInfo area) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: area.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Area Info: ${area.name}"),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Area / Barangay Name", border: OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? "Enter area name" : null,
                  ),
                ],
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
                  final updated = area.copyWith(name: nameController.text.trim());
                  dataService.editArea(updated);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Area info successfully updated")),
                  );
                }
              },
              child: const Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  // Confirm delete area popup dialog
  void _confirmDeleteArea(BuildContext context, AreaInfo area) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Area"),
          content: Text("Are you sure you want to permanently delete area '${area.name}' from the dashboard monitors?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.dangerRed, foregroundColor: Colors.white),
              onPressed: () {
                dataService.deleteArea(area.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Area '${area.name}' deleted successfully")),
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
