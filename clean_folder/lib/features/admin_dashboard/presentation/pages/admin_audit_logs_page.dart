import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:printing/printing.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/admin_dashboard/domain/entities/audit_log_entity.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/audit_log_remote_data_source.dart';

class AdminAuditLogsPage extends StatefulWidget {
  const AdminAuditLogsPage({super.key});

  @override
  State<AdminAuditLogsPage> createState() => _AdminAuditLogsPageState();
}

class _AdminAuditLogsPageState extends State<AdminAuditLogsPage> {
  String _searchQuery = "";
  String _actionFilter = "All";
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Bar ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3A4B6B), Color(0xFF1E2D4A)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.history_edu_rounded,
                      color: Color(0xFF00E5FF),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Administrative System Audit Logs",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE8F0FE),
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "Immutable ledger of dispatch status updates, sirens, moderation, and blotter exports",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7B8DB0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Stream snapshot for CSV download button
              StreamBuilder<List<AuditLogEntity>>(
                stream: sl<AuditLogRemoteDataSource>().streamAuditLogs(),
                builder: (context, snapshot) {
                  final logs = snapshot.data ?? [];
                  return OutlinedButton.icon(
                    onPressed: (_isExporting || logs.isEmpty)
                        ? null
                        : () => _exportAuditLogsCsv(logs),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00E5FF), width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      backgroundColor:
                          const Color(0xFF00E5FF).withValues(alpha: 0.08),
                    ),
                    icon: const Icon(
                      Icons.download_rounded,
                      size: 17,
                      color: Color(0xFF00E5FF),
                    ),
                    label: const Text(
                      "Export Audit CSV",
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Search & Filter Row ────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1627),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E2D4A)),
                  ),
                  child: TextField(
                    style: const TextStyle(
                      color: Color(0xFFE8F0FE),
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search audit logs by admin, action, target, or details...",
                      hintStyle: const TextStyle(
                        color: Color(0xFF5A6E8C),
                        fontSize: 12.5,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF7B8DB0),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0D1627),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Action Filter Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1627),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2D4A)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _actionFilter,
                    dropdownColor: const Color(0xFF0D1627),
                    style: const TextStyle(
                      color: Color(0xFFE8F0FE),
                      fontSize: 13,
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF00E5FF),
                    ),
                    items: const [
                      DropdownMenuItem(value: "All", child: Text("All Actions")),
                      DropdownMenuItem(
                        value: "Status Update",
                        child: Text("Status Updates"),
                      ),
                      DropdownMenuItem(
                        value: "Emergency Siren",
                        child: Text("Emergency Sirens"),
                      ),
                      DropdownMenuItem(
                        value: "Citizen Moderation",
                        child: Text("Citizen Moderation"),
                      ),
                      DropdownMenuItem(
                        value: "Report Export",
                        child: Text("Report Exports"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _actionFilter = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Streamed Audit Log Table ───────────────────────────────
          Expanded(
            child: StreamBuilder<List<AuditLogEntity>>(
              stream: sl<AuditLogRemoteDataSource>().streamAuditLogs(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error streaming audit records: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                  );
                }

                final allLogs = snapshot.data!;
                final filteredLogs = allLogs.where((log) {
                  final q = _searchQuery.toLowerCase();
                  final matchesSearch = log.adminName.toLowerCase().contains(q) ||
                      log.adminEmail.toLowerCase().contains(q) ||
                      log.actionType.toLowerCase().contains(q) ||
                      log.details.toLowerCase().contains(q) ||
                      (log.targetId ?? '').toLowerCase().contains(q);

                  final matchesAction = _actionFilter == "All" ||
                      log.actionType.toLowerCase() == _actionFilter.toLowerCase();

                  return matchesSearch && matchesAction;
                }).toList();

                return Custom3dCard(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 22,
                  child: filteredLogs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                color: const Color(0xFF2A3F60),
                                size: 52,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "No audit log entries found for this filter.",
                                style: TextStyle(
                                  color: Color(0xFF7B8DB0),
                                  fontSize: 13,
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
                              headingRowHeight: 48,
                              headingRowColor: WidgetStateProperty.all(
                                const Color(0xFF060D1A),
                              ),
                              dataRowColor: WidgetStateProperty.resolveWith(
                                (states) => states.contains(WidgetState.hovered)
                                    ? const Color(0xFF0D1627)
                                        .withValues(alpha: 0.8)
                                    : Colors.transparent,
                              ),
                              dividerThickness: 0.5,
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    "Timestamp",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF7B8DB0),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Admin Officer",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF7B8DB0),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Action Type",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF7B8DB0),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Target ID",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF7B8DB0),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Operational Details",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF7B8DB0),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                              rows: filteredLogs.map((log) {
                                final color = _actionColor(log.actionType);
                                final d = log.timestamp;
                                final timeStr =
                                    "${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}";

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        timeStr,
                                        style: const TextStyle(
                                          color: Color(0xFF7B8DB0),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            log.adminName,
                                            style: const TextStyle(
                                              color: Color(0xFFE8F0FE),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            log.adminEmail,
                                            style: const TextStyle(
                                              color: Color(0xFF5A6E8C),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.14),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: color.withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: Text(
                                          log.actionType,
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        (log.targetId != null &&
                                                log.targetId!.isNotEmpty)
                                            ? (log.targetId!.length > 10
                                                ? log.targetId!.substring(0, 10)
                                                : log.targetId!)
                                            : "—",
                                        style: const TextStyle(
                                          color: Color(0xFF00E5FF),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 320,
                                        child: Text(
                                          log.details,
                                          style: const TextStyle(
                                            color: Color(0xFFB0C4DE),
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _actionColor(String action) {
    final a = action.toLowerCase();
    if (a.contains('siren') || a.contains('broadcast')) {
      return const Color(0xFFFF3B30);
    }
    if (a.contains('moderation') || a.contains('suspend')) {
      return const Color(0xFFFF9F0A);
    }
    if (a.contains('export') || a.contains('pdf') || a.contains('csv')) {
      return const Color(0xFF00E5FF);
    }
    if (a.contains('status') || a.contains('solved')) {
      return const Color(0xFF30D158);
    }
    return const Color(0xFF7C4DFF);
  }

  Future<void> _exportAuditLogsCsv(List<AuditLogEntity> logs) async {
    setState(() => _isExporting = true);
    try {
      final List<List<dynamic>> rows = [
        [
          "Log ID",
          "Timestamp",
          "Admin Name",
          "Admin Email",
          "Action Type",
          "Target ID",
          "Operational Details",
        ],
      ];

      for (final log in logs) {
        rows.add([
          log.id,
          log.timestamp.toIso8601String(),
          log.adminName,
          log.adminEmail,
          log.actionType,
          log.targetId ?? '',
          log.details,
        ]);
      }

      final csvString = const ListToCsvConverter().convert(rows);
      final bytes = Uint8List.fromList(utf8.encode(csvString));

      final filename =
          "Barangay_Moonwalk_Audit_Trail_${DateTime.now().millisecondsSinceEpoch}.csv";

      await Printing.sharePdf(bytes: bytes, filename: filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✓ Audit trail CSV exported: $filename"),
            backgroundColor: const Color(0xFF30D158),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to export audit CSV: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
