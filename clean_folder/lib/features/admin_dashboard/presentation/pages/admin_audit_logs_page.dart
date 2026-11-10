import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:printing/printing.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/admin_dashboard/domain/entities/audit_log_entity.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/audit_log_remote_data_source.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header Bar ─────────────────────────────────────────────
          AdminPageTitle(
            title: "Administrative System Audit Logs",
            subtitle:
                "Immutable ledger of dispatch status updates, sirens, moderation, and blotter exports",
            trailing: [
              // Stream snapshot for CSV download button
              StreamBuilder<List<AuditLogEntity>>(
                stream: sl<AuditLogRemoteDataSource>().streamAuditLogs(),
                builder: (context, snapshot) {
                  final logs = snapshot.data ?? [];
                  return AdminButton(
                    label: "Export Audit CSV",
                    icon: Icons.download_rounded,
                    style: AdminButtonStyle.ghost,
                    onPressed: (_isExporting || logs.isEmpty)
                        ? null
                        : () => _exportAuditLogsCsv(logs),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Search & Filter Row ────────────────────────────────────
          AdminSearchField(
            hint: "Search audit logs by admin, action, target, or details...",
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 12),

          // Action Filter Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (value, label) in const [
                ("All", "All Actions"),
                ("Status Update", "Status Updates"),
                ("Emergency Siren", "Emergency Sirens"),
                ("Citizen Moderation", "Citizen Moderation"),
                ("Report Export", "Report Exports"),
              ])
                _ActionFilterChip(
                  label: label,
                  selected: _actionFilter == value,
                  onTap: () => setState(() => _actionFilter = value),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Streamed Audit Log Table ───────────────────────────────
          Expanded(
            child: StreamBuilder<List<AuditLogEntity>>(
              stream: sl<AuditLogRemoteDataSource>().streamAuditLogs(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Error streaming audit records: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AdminColors.dangerText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(color: AdminColors.cyan),
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

                return AdminPanel(
                  padding: EdgeInsets.zero,
                  child: filteredLogs.isEmpty
                      ? const Center(
                          child: SingleChildScrollView(
                            child: AdminEmptyState(
                              icon: Icons.verified_user_outlined,
                              title:
                                  "No audit log entries found for this filter.",
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          // Fills the card on wide screens and scrolls
                          // sideways on narrow ones.
                          child: LayoutBuilder(
                            builder: (context, constraints) =>
                                SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth,
                                      ),
                                      child: DividerTheme(
                                        data: const DividerThemeData(
                                          color: AdminTable.divider,
                                        ),
                                        child: _buildAuditTable(filteredLogs),
                                      ),
                                    ),
                                  ),
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

  Widget _buildAuditTable(List<AuditLogEntity> filteredLogs) {
    return DataTable(
      headingRowHeight: 48,
      dataRowMinHeight: 52,
      dataRowMaxHeight: 52,
      horizontalMargin: 18,
      columnSpacing: 28,
      dataRowColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? AdminTable.hoverRow
            : Colors.transparent,
      ),
      dividerThickness: 1,
      columns: [
        _tableColumn("Timestamp"),
        _tableColumn("Admin Officer"),
        _tableColumn("Action Type"),
        _tableColumn("Target ID"),
        _tableColumn("Operational Details"),
      ],
      rows: filteredLogs.map((log) {
        final tone = _actionTone(log.actionType);
        final d = log.timestamp;
        final timeStr =
            "${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}";

        return DataRow(
          cells: [
            DataCell(Text(timeStr, style: AdminTable.cellMuted)),
            DataCell(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.adminName,
                    style: const TextStyle(
                      color: AdminColors.textBody,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    log.adminEmail,
                    style: const TextStyle(
                      color: AdminColors.textHint,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(AdminPill(label: log.actionType, tone: tone)),
            DataCell(
              Text(
                (log.targetId != null && log.targetId!.isNotEmpty)
                    ? (log.targetId!.length > 10
                          ? log.targetId!.substring(0, 10)
                          : log.targetId!)
                    : "—",
                style: AdminTable.cellStrong,
              ),
            ),
            DataCell(
              SizedBox(
                width: 320,
                child: Text(
                  log.details,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AdminTable.cellMuted,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// A table heading, in capitals as on the board.
  DataColumn _tableColumn(String label) {
    return DataColumn(
      label: Text(label.toUpperCase(), style: AdminTable.header),
    );
  }

  AdminTone _actionTone(String action) {
    final a = action.toLowerCase();
    if (a.contains('siren') || a.contains('broadcast')) {
      return AdminTone.red;
    }
    if (a.contains('moderation') || a.contains('suspend')) {
      return AdminTone.yellow;
    }
    if (a.contains('export') || a.contains('pdf') || a.contains('csv')) {
      return AdminTone.cyan;
    }
    if (a.contains('status') || a.contains('solved')) {
      return AdminTone.blue;
    }
    return AdminTone.violet;
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
            backgroundColor: AdminColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to export audit CSV: $e"),
            backgroundColor: AdminColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

/// A pill for one action filter. Selected is ResQuick blue, the rest faint
/// glass, as on the audit board.
class _ActionFilterChip extends StatelessWidget {
  const _ActionFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AdminColors.primary,
                        Color.lerp(
                          AdminColors.primary,
                          AdminColors.primaryDeep,
                          0.5,
                        )!,
                      ],
                    )
                  : null,
              color: selected ? null : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.14),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AdminColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AdminColors.textBody,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
