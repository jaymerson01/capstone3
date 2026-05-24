import 'package:flutter/material.dart';
import '../services/admin_data_service.dart';

class AdminAuditLogsPage extends StatelessWidget {
  const AdminAuditLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = AdminDataService();

    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text(
                      "Timestamp",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Admin Name/ID",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Action Type",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Target / Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                rows: dataService.auditLogs.map((log) {
                  return DataRow(
                    cells: [
                      DataCell(Text(log["time"] ?? "")),
                      DataCell(Text(log["admin"] ?? "")),
                      DataCell(Text(log["action"] ?? "")),
                      DataCell(Text(log["details"] ?? "")),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}