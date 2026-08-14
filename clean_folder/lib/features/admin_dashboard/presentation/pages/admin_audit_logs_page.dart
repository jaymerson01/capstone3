import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';

class AdminAuditLogsPage extends StatelessWidget {
  const AdminAuditLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy audit logs representing data that would come from a BLoC
    final List<Map<String, String>> auditLogs = [
      {
        "time": "10:42 AM",
        "admin": "Admin User",
        "action": "Status Update",
        "details": "Changed incident INC-092 status to 'In Progress'",
      },
      {
        "time": "09:15 AM",
        "admin": "System Auto",
        "action": "Auto Dispatch",
        "details": "Dispatched emergency units to Zone 4",
      },
      {
        "time": "Yesterday, 11:30 PM",
        "admin": "Admin User",
        "action": "User Mgt",
        "details": "Archived user U-008",
      },
      {
        "time": "Yesterday, 08:20 PM",
        "admin": "Security Chief",
        "action": "Status Update",
        "details": "Marked incident INC-088 as 'Solved'",
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "System Audit Logs",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE8F0FE),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Immutable record of administrative actions and security dispatches.",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7B8DB0),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Custom3dCard(
              padding: const EdgeInsets.all(12),
              borderRadius: 22,
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    headingRowHeight: 48,
                    headingRowColor:
                        WidgetStateProperty.all(const Color(0xFF060D1A)),
                    dataRowColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.hovered)
                            ? const Color(0xFF0D1627).withValues(alpha: 0.8)
                            : Colors.transparent),
                    dividerThickness: 0.5,
                    columns: const [
                      DataColumn(
                        label: Text(
                          "Timestamp",
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7B8DB0),
                              fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Admin Name/ID",
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7B8DB0),
                              fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Action Type",
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7B8DB0),
                              fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Target / Details",
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7B8DB0),
                              fontSize: 12),
                        ),
                      ),
                    ],
                    rows: auditLogs.map((log) {
                      return DataRow(
                        cells: [
                          DataCell(Text(log["time"] ?? "",
                              style: const TextStyle(
                                  color: Color(0xFF7B8DB0), fontSize: 12))),
                          DataCell(Text(log["admin"] ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE8F0FE),
                                  fontSize: 12))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A84FF)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                log["action"] ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A84FF),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(log["details"] ?? "",
                              style: const TextStyle(
                                  color: Color(0xFFE8F0FE), fontSize: 12))),
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
  }
}
