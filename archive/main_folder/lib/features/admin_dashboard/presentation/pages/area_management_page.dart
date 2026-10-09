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
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textDark,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _showAddAreaDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add New Area"),
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
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("ID", style: TextStyle(color: AdminColors.textDark, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Area", style: TextStyle(color: AdminColors.textDark, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Incidents", style: TextStyle(color: AdminColors.textDark, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Actions", style: TextStyle(color: AdminColors.textDark, fontWeight: FontWeight.bold))),
                      ],
                      rows: dataService.areas.map(
                        (area) {
                          return DataRow(
                            cells: [
                              DataCell(Text(area.id, style: const TextStyle(color: AdminColors.textDark))),
                              DataCell(Text(area.name, style: const TextStyle(color: AdminColors.textDark))),
                              DataCell(Text(area.incidentsCount.toString(), style: const TextStyle(color: AdminColors.textDark))),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        _showEditAreaDialog(
                                          context,
                                          area,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        dataService.deleteArea(area.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ).toList(),
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
          backgroundColor: Colors.white,
          title: const Text("Add New Area", style: TextStyle(color: AdminColors.textDark)),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: nameController,
              style: const TextStyle(color: AdminColors.textDark, fontSize: 14),
              decoration: const InputDecoration(
                labelText: "Area Name",
                labelStyle: TextStyle(color: AdminColors.textLight),
                border: OutlineInputBorder(),
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
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
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
                    content: Text(
                      "${newArea.name} added successfully",
                    ),
                  ),
                );
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showEditAreaDialog(
    BuildContext context,
    AreaInfo area,
  ) {
    final nameController = TextEditingController(
      text: area.name,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Edit Area", style: TextStyle(color: AdminColors.textDark)),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: nameController,
              style: const TextStyle(color: AdminColors.textDark, fontSize: 14),
              decoration: const InputDecoration(
                labelText: "Area Name",
                labelStyle: TextStyle(color: AdminColors.textLight),
                border: OutlineInputBorder(),
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
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final updated = area.copyWith(
                  name: nameController.text.trim(),
                );

                dataService.editArea(updated);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Area updated successfully",
                    ),
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
