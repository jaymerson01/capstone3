import 'package:flutter/material.dart';
import '../models/area.dart';
import '../services/admin_data_service.dart';
import '../constants/admin_colors.dart';
import '../../widgets/custom_3d_card.dart';

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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Area Management",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AdminColors.textDark,
                    ),
                  ),
                  Row(
                    children: [
                      const Text("Show Archived", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AdminColors.textDark)),
                      Switch(
                        value: dataService.showArchivedAreas,
                        activeThumbColor: AdminColors.primaryRose,
                        onChanged: (val) {
                          dataService.toggleArchivedAreas();
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primaryRose,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          _showAddAreaDialog(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add New Area", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Custom3dCard(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 22,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowHeight: 48,
                      columns: const [
                        DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Area Name", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Incidents Count", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: dataService.areas.map((area) {
                        return DataRow(
                          cells: [
                            DataCell(Text(area.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(area.name)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AdminColors.accentGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  area.incidentsCount.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primaryRose),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      _showEditAreaDialog(context, area);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.archive, color: Colors.red),
                                    onPressed: () {
                                      dataService.archiveArea(area.id);
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
            ],
          ),
        );
      },
    );
  }

  void _showAddAreaDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Add New Area", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Area Name",
                filled: true,
                fillColor: AdminColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
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
                final newArea = AreaInfo(
                  id: "AREA-${DateTime.now().millisecondsSinceEpoch}",
                  name: nameController.text.trim(),
                  incidentsCount: 0,
                );

                dataService.addArea(newArea);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${newArea.name} added successfully"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text("Add Area"),
            ),
          ],
        );
      },
    );
  }

  void _showEditAreaDialog(BuildContext context, AreaInfo area) {
    final nameController = TextEditingController(text: area.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Edit Area", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Area Name",
                filled: true,
                fillColor: AdminColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
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
                final updated = area.copyWith(name: nameController.text.trim());

                dataService.editArea(updated);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Area updated successfully"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}