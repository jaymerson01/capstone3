import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';

class AreaInfoDummy {
  final String id;
  final String name;
  final int incidentsCount;

  AreaInfoDummy({required this.id, required this.name, required this.incidentsCount});
}

class AreaManagementPage extends StatefulWidget {
  const AreaManagementPage({super.key});

  @override
  State<AreaManagementPage> createState() => _AreaManagementPageState();
}

class _AreaManagementPageState extends State<AreaManagementPage> {
  bool _showArchivedAreas = false;
  
  // Dummy data representing state from BLoC
  final List<AreaInfoDummy> _dummyAreas = [
    AreaInfoDummy(id: "AREA-01", name: "Downtown District", incidentsCount: 42),
    AreaInfoDummy(id: "AREA-02", name: "North Hills", incidentsCount: 15),
    AreaInfoDummy(id: "AREA-03", name: "Southside Valley", incidentsCount: 28),
    AreaInfoDummy(id: "AREA-04", name: "Westlake", incidentsCount: 8),
  ];

  @override
  Widget build(BuildContext context) {
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
                    value: _showArchivedAreas,
                    activeThumbColor: AdminColors.primaryRose,
                    onChanged: (val) {
                      setState(() {
                        _showArchivedAreas = val;
                      });
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
                    DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark))),
                    DataColumn(label: Text("Area Name", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark))),
                    DataColumn(label: Text("Incidents Count", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark))),
                    DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark))),
                  ],
                  rows: _dummyAreas.map((area) {
                    return DataRow(
                      cells: [
                        DataCell(Text(area.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark))),
                        DataCell(Text(area.name, style: const TextStyle(color: AdminColors.textDark))),
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Mock: Area archived. Pending BLoC.")));
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
  }

  void _showAddAreaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Add New Area", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const SizedBox(
            width: 400,
            child: Text("BLoC integration pending for adding areas."),
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

  void _showEditAreaDialog(BuildContext context, AreaInfoDummy area) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Edit Area", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const SizedBox(
            width: 400,
            child: Text("BLoC integration pending for editing areas."),
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
}
