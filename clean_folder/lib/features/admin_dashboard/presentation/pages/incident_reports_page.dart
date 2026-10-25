import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/core/utils/incident_triage_helper.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/presentation/widgets/in_app_evidence_player_dialog.dart';
import 'package:community_safety_app/core/presentation/widgets/in_app_image_viewer_dialog.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_header_parts.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';

class IncidentReportsPage extends StatefulWidget {
  const IncidentReportsPage({super.key});

  @override
  State<IncidentReportsPage> createState() => _IncidentReportsPageState();
}

class _IncidentReportsPageState extends State<IncidentReportsPage> {
  String searchQuery = "";
  String statusFilter = "All";
  bool showArchivedReports = false;
  String sortBy = "latest"; // 'latest', 'urgency', 'corroborated', 'oldest_pending'
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageTitle(
            title: "Incident Reports",
            trailing: [
              AdminSegmented<bool>(
                segments: const [(false, "Active"), (true, "Archived")],
                value: showArchivedReports,
                onChanged: (val) {
                  setState(() {
                    showArchivedReports = val;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildToolbar(),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<IncidentBloc, IncidentState>(
              builder: (context, state) {
                if (state is IncidentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is IncidentError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AdminColors.dangerText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                } else if (state is IncidentLoaded) {
                  final filteredReports = state.incidents.where((report) {
                    final isArchived =
                        report.status.toLowerCase() == 'archived';
                    if (showArchivedReports && !isArchived) return false;
                    if (!showArchivedReports && isArchived) return false;

                    final matchesSearch = report.id
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        report.category
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        report.reporterId
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        (report.reporterName ?? "")
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        (report.resolvedAddress ?? "")
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        (report.areaSector ?? "")
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase());

                    final reportStatusLabel =
                        _getStatusLabel(report.status);
                    final matchesStatus = statusFilter == "All" ||
                        reportStatusLabel == statusFilter;

                    return matchesSearch && matchesStatus;
                  }).toList();

                  // Apply Multi-Criteria Sorting Hierarchy
                  if (_sortColumnIndex != null) {
                    if (_sortColumnIndex == 2) {
                      // Sort by Urgency Weight
                      filteredReports.sort((a, b) {
                        final wa = IncidentTriageHelper.getUrgencyWeight(a.urgencyStatus);
                        final wb = IncidentTriageHelper.getUrgencyWeight(b.urgencyStatus);
                        return _sortAscending ? wa.compareTo(wb) : wb.compareTo(wa);
                      });
                    } else if (_sortColumnIndex == 3) {
                      // Sort by Corroborated / Affected count
                      filteredReports.sort((a, b) => _sortAscending
                          ? a.upvoteCount.compareTo(b.upvoteCount)
                          : b.upvoteCount.compareTo(a.upvoteCount));
                    } else if (_sortColumnIndex == 6) {
                      // Sort by Date
                      filteredReports.sort((a, b) => _sortAscending
                          ? a.timestamp.compareTo(b.timestamp)
                          : b.timestamp.compareTo(a.timestamp));
                    }
                  } else {
                    switch (sortBy) {
                      case "urgency":
                        filteredReports.sort((a, b) {
                          final wa = IncidentTriageHelper.getUrgencyWeight(a.urgencyStatus);
                          final wb = IncidentTriageHelper.getUrgencyWeight(b.urgencyStatus);
                          final cmp = wb.compareTo(wa);
                          return cmp != 0 ? cmp : b.timestamp.compareTo(a.timestamp);
                        });
                        break;
                      case "corroborated":
                        filteredReports.sort((a, b) {
                          final cmp = b.upvoteCount.compareTo(a.upvoteCount);
                          return cmp != 0 ? cmp : b.timestamp.compareTo(a.timestamp);
                        });
                        break;
                      case "oldest_pending":
                        filteredReports.sort((a, b) {
                          final aPending = a.status.toLowerCase() == 'pending' ? 0 : 1;
                          final bPending = b.status.toLowerCase() == 'pending' ? 0 : 1;
                          if (aPending != bPending) return aPending.compareTo(bPending);
                          return a.timestamp.compareTo(b.timestamp);
                        });
                        break;
                      case "latest":
                      default:
                        filteredReports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                        break;
                    }
                  }

                  return _buildReportsTable(context, filteredReports);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Search, status filter and the priority queue. One row on wide
  /// screens; the filters drop under the search bar on narrow ones.
  Widget _buildToolbar() {
    final Widget search = AdminSearchField(
      hint: "Search by ID, type, reporter, location...",
      onChanged: (value) => setState(() => searchQuery = value),
    );

    final Widget filters = Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AdminSelect<String>(
          value: statusFilter,
          items: const [
            ("All", "All Statuses"),
            ("Pending", "Pending"),
            ("In Progress", "In Progress"),
            ("Solved", "Solved"),
            ("Spam", "Spam"),
          ],
          onChanged: (value) {
            setState(() => statusFilter = value);
          },
        ),
        // Priority Triage Hierarchy Toolbar
        const Text(
          "PRIORITY QUEUE:",
          style: TextStyle(
            color: AdminColors.textHint,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        AdminSelect<String>(
          value: sortBy,
          // Cyan while the queue order applies; a column sort replaces it.
          accent: _sortColumnIndex == null,
          items: const [
            ("latest", "Latest First"),
            ("urgency", "Critical & Urgent First"),
            ("corroborated", "Most Corroborated / Affected"),
            ("oldest_pending", "Oldest Pending Backlog"),
          ],
          onChanged: (key) {
            setState(() {
              sortBy = key;
              _sortColumnIndex = null;
            });
          },
        ),
      ],
    );

    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth < 860) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [search, const SizedBox(height: 12), filters],
          );
        }
        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            filters,
          ],
        );
      },
    );
  }

  /// The reports table: the data columns scroll sideways and the actions
  /// column stays pinned on the right.
  Widget _buildReportsTable(
    BuildContext context,
    List<IncidentEntity> filteredReports,
  ) {
    if (filteredReports.isEmpty) {
      return const AdminPanel(
        padding: EdgeInsets.zero,
        child: Center(
          child: SingleChildScrollView(
            child: AdminEmptyState(
              icon: Icons.inbox_outlined,
              title: "No incident reports found",
            ),
          ),
        ),
      );
    }

    final Widget reportColumns = DataTable(
      headingRowHeight: 50,
      dataRowMinHeight: 60,
      dataRowMaxHeight: 60,
      dataRowColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? AdminTable.hoverRow
            : Colors.transparent,
      ),
      dividerThickness: 1,
      horizontalMargin: 16,
      columnSpacing: 20,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: [
        const DataColumn(label: _ColumnLabel("Report ID")),
        const DataColumn(label: _ColumnLabel("Category")),
        DataColumn(
          label: const _ColumnLabel("Urgency"),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            });
          },
        ),
        DataColumn(
          label: const _ColumnLabel("Corroborated / Affected"),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            });
          },
        ),
        const DataColumn(label: _ColumnLabel("Reporter")),
        const DataColumn(label: _ColumnLabel("Location")),
        DataColumn(
          label: const _ColumnLabel("Date"),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            });
          },
        ),
        const DataColumn(label: _ColumnLabel("Status")),
      ],
      rows: filteredReports.map((report) {
        final statusTone = _getStatusTone(report.status);
        final statusLabel = _getStatusLabel(report.status);
        final isSpam = statusLabel == "Spam";

        final urgency = report.urgencyStatus?.toUpperCase() ?? "PENDING";
        final urgencyTone = _getUrgencyTone(urgency);

        final affectedTone = (report.upvoteCount + 1) >= 5
            ? AdminTone.red
            : ((report.upvoteCount + 1) >= 3
                  ? AdminTone.orange
                  : AdminTone.cyan);

        final reporterDisplayName =
            (report.reporterName != null && report.reporterName!.isNotEmpty)
            ? report.reporterName!
            : (report.reporterId.length > 8
                  ? report.reporterId.substring(0, 8)
                  : report.reporterId);

        final locationDisplay = BarangaySectorHelper.formatReadableAddress(
          resolvedAddress: report.resolvedAddress,
          areaSector: report.areaSector,
          latitude: report.latitude,
          longitude: report.longitude,
        );

        return DataRow(
          cells: [
            _cell(
              Text(
                report.id.length > 8 ? report.id.substring(0, 8) : report.id,
                style: AdminTable.cellStrong,
              ),
              dimmed: isSpam,
            ),
            _cell(
              Text(
                report.category,
                style: const TextStyle(
                  color: AdminColors.textBody,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              dimmed: isSpam,
            ),
            _cell(
              AdminPill(
                label: urgency,
                tone: urgencyTone,
                solid: urgencyTone == AdminTone.red,
              ),
              dimmed: isSpam,
            ),
            _cell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 14,
                    color: affectedTone.text,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${report.upvoteCount + 1} Affected",
                    style: TextStyle(
                      color: affectedTone.text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              dimmed: isSpam,
            ),
            _cell(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reporterDisplayName, style: AdminTable.cell),
                  if (report.isReportingOnBehalf)
                    Text(
                      "👥 For: ${report.victimName ?? 'Relative'}",
                      style: const TextStyle(
                        color: AdminColors.orangeLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (report.isAnonymous)
                    const Text(
                      "Anon to Public",
                      style: TextStyle(
                        color: AdminColors.orangeLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              dimmed: isSpam,
            ),
            _cell(
              Tooltip(
                message: locationDisplay,
                child: SizedBox(
                  width: 120,
                  child: Text(
                    locationDisplay,
                    style: AdminTable.cellMuted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              dimmed: isSpam,
            ),
            _cell(
              Text(_formatDate(report.timestamp), style: AdminTable.cellMuted),
              dimmed: isSpam,
            ),
            _cell(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminPill(
                    label: statusLabel.toUpperCase(),
                    tone: statusTone,
                  ),
                  if (report.isInProgress &&
                      report.estimatedResponseTime != null &&
                      report.estimatedResponseTime!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 11,
                          color: AdminColors.cyanSoft,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "ETA: ${report.estimatedResponseTime!}",
                          style: const TextStyle(
                            color: AdminColors.cyanSoft,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              dimmed: isSpam,
            ),
          ],
        );
      }).toList(),
    );

    final Widget actionsColumn = DataTable(
      headingRowHeight: 50,
      dataRowMinHeight: 60,
      dataRowMaxHeight: 60,
      dataRowColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? AdminTable.hoverRow
            : Colors.transparent,
      ),
      dividerThickness: 1,
      horizontalMargin: 14,
      columnSpacing: 0,
      columns: const [DataColumn(label: _ColumnLabel("Actions"))],
      rows: filteredReports.map((report) {
        return DataRow(
          cells: [
            _cell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminIconAction(
                    icon: Icons.visibility_outlined,
                    tooltip: "View Details",
                    onPressed: () {
                      _showReportDetails(context, report);
                    },
                  ),
                  const SizedBox(width: 6),
                  AdminIconAction(
                    icon: Icons.edit_outlined,
                    tooltip: "Edit Status",
                    tone: AdminTone.cyan,
                    onPressed: () {
                      _showEditReportDialog(context, report);
                    },
                  ),
                  const SizedBox(width: 6),
                  AdminIconAction(
                    icon: Icons.report_gmailerrorred,
                    tooltip: "Mark as Spam",
                    tone: AdminTone.red,
                    onPressed: () {
                      context.read<IncidentBloc>().add(
                        UpdateIncidentStatusRequested(report.id, 'spam'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AdminColors.surfaceDeep,
                          content: Text(
                            "Report #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)} marked as Spam",
                            style: const TextStyle(
                              color: AdminColors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              dimmed: _getStatusLabel(report.status) == "Spam",
            ),
          ],
        );
      }).toList(),
    );

    return AdminPanel(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: DividerTheme(
          data: const DividerThemeData(color: AdminTable.divider),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontally scrollable metadata columns
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, constraints) => Scrollbar(
                      controller: _horizontalScrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        // Stretches the columns to fill wide panels.
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          // Tints the arrow on the sorted column.
                          child: IconTheme.merge(
                            data: const IconThemeData(
                              color: AdminColors.cyanText,
                            ),
                            child: reportColumns,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Sticky / Frozen Actions Column on the far right
                Container(
                  decoration: BoxDecoration(
                    color: AdminColors.cardBackground,
                    border: Border(
                      left: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 10,
                        offset: const Offset(-3, 0),
                      ),
                    ],
                  ),
                  child: actionsColumn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A table cell. Spam rows are dimmed.
  DataCell _cell(Widget child, {bool dimmed = false}) {
    return DataCell(dimmed ? Opacity(opacity: 0.75, child: child) : child);
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  String _formatDateTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? "PM" : "AM";
    final minute = date.minute.toString().padLeft(2, '0');
    return "${date.month}/${date.day}/${date.year} • $hour:$minute $period";
  }

  String _getStatusLabel(String status) {
    switch (
        status.toLowerCase().replaceAll(' ', '').replaceAll('_', '').trim()) {
      case 'pending':
        return 'Pending';
      case 'inprogress':
        return 'In Progress';
      case 'solved':
      case 'resolved':
        return 'Solved';
      case 'spam':
        return 'Spam';
      case 'archived':
        return 'Archived';
      default:
        return 'Pending';
    }
  }

  AdminTone _getStatusTone(String status) {
    switch (
        status.toLowerCase().replaceAll(' ', '').replaceAll('_', '').trim()) {
      case 'pending':
        return AdminTone.yellow;
      case 'inprogress':
        return AdminTone.blue;
      case 'solved':
      case 'resolved':
        return AdminTone.green;
      case 'spam':
        return AdminTone.slate;
      case 'archived':
        return AdminTone.slate;
      default:
        return AdminTone.slate;
    }
  }

  AdminTone _getUrgencyTone(String urgency) {
    switch (urgency.toUpperCase().trim()) {
      case 'CRITICAL':
        return AdminTone.red; // Crimson Red, shown solid
      case 'HIGH':
        return AdminTone.orange; // Amber Orange
      case 'MEDIUM':
        return AdminTone.yellow;
      case 'LOW':
        return AdminTone.slate; // Slate Gray
      default:
        return AdminTone.slate;
    }
  }

  void _showEditReportDialog(BuildContext context, IncidentEntity report) {
    String selectedStatus = _getStatusLabel(report.status);
    final TextEditingController notesController =
        TextEditingController(text: report.dispatcherNotes ?? "");
    final TextEditingController etaController =
        TextEditingController(text: report.estimatedResponseTime ?? "");

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AdminDialog(
              tone: AdminTone.cyan,
              icon: Icons.edit_note,
              title:
                  "Dispatch Actions • #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)}",
              subtitle: report.category,
              maxWidth: 480,
              actions: [
                AdminButton(
                  label: "Cancel",
                  style: AdminButtonStyle.ghost,
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                AdminButton(
                  label: "Save & Broadcast Status",
                  onPressed: () {
                    final notes = notesController.text.trim();
                    final eta = etaController.text.trim();
                    final normalizedStatus =
                        IncidentStatusExtension.normalize(selectedStatus);
                    context.read<IncidentBloc>().add(
                          UpdateIncidentStatusRequested(
                            report.id,
                            normalizedStatus,
                            dispatcherNotes: notes.isEmpty ? null : notes,
                            estimatedResponseTime:
                                (normalizedStatus == 'in_progress' && eta.isNotEmpty)
                                    ? eta
                                    : (normalizedStatus == 'resolved' ||
                                            normalizedStatus == 'solved'
                                        ? null
                                        : (eta.isNotEmpty ? eta : null)),
                          ),
                        );
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AdminColors.cardBackground,
                        content: Text(
                          "Incident #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)} status updated to '$selectedStatus'!",
                          style: const TextStyle(
                              color: AdminColors.success,
                              fontWeight: FontWeight.bold),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminFieldLabel("RESOLUTION STAGE"),
                  Column(
                    spacing: 8,
                    children: [
                      for (final (String value, String label) in const [
                        ("Pending", "Pending (Awaiting Review)"),
                        ("In Progress", "In Progress (Unit Dispatched)"),
                        ("Solved", "Solved (Incident Resolved)"),
                        ("Spam", "Spam / False Alarm"),
                        ("Archived", "Archived / Closed"),
                      ])
                        AdminChoiceTile(
                          label: label,
                          selected: selectedStatus == value,
                          onTap: () {
                            setDialogState(() {
                              selectedStatus = value;
                            });
                          },
                        ),
                    ],
                  ),
                  if (selectedStatus == "In Progress") ...[
                    const SizedBox(height: 18),
                    const AdminFieldLabel(
                      "ESTIMATED TIME OF ARRIVAL (ETA)",
                      trailing: AdminPill(
                        label: "CITIZEN VISIBLE",
                        tone: AdminTone.cyan,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        "5-10 mins",
                        "10-15 mins",
                        "15-20 mins",
                        "20-30 mins",
                        "30-45 mins",
                      ].map((chip) {
                        final isSelected = etaController.text == chip;
                        return AdminChoiceChip(
                          label: chip,
                          selected: isSelected,
                          onTap: () {
                            setDialogState(() {
                              etaController.text = chip;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: etaController,
                      style: adminInputText,
                      decoration: adminInputDecoration(
                        hint: "Or type custom ETA (e.g. 8 mins, On scene)...",
                        icon: Icons.timer_outlined,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const AdminFieldLabel("DISPATCHER & OPERATIONAL NOTES"),
                  TextField(
                    controller: notesController,
                    maxLines: 4,
                    style: adminInputText,
                    decoration: adminInputDecoration(
                      hint:
                          "Log responder dispatch units, field actions, or resident advisory...",
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReportDetails(BuildContext context, IncidentEntity report) {
    final statusTone = _getStatusTone(report.status);
    final statusLabel = _getStatusLabel(report.status);
    final urgency = report.urgencyStatus?.toUpperCase() ?? "PENDING";
    final urgencyTone = _getUrgencyTone(urgency);

    final fullAddress = BarangaySectorHelper.formatReadableAddress(
      resolvedAddress: report.resolvedAddress,
      areaSector: report.areaSector,
      latitude: report.latitude,
      longitude: report.longitude,
    );

    final hasPhoto =
        report.photoUrl != null && report.photoUrl!.trim().isNotEmpty;
    final isRemotePhoto = hasPhoto &&
        (report.photoUrl!.startsWith('http://') ||
            report.photoUrl!.startsWith('https://'));
    final isLocalPhoto = hasPhoto && !isRemotePhoto;

    final hasVideo =
        report.videoUrl != null && report.videoUrl!.trim().isNotEmpty;
    final isRemoteVideo = hasVideo &&
        (report.videoUrl!.startsWith('http://') ||
            report.videoUrl!.startsWith('https://'));
    final isLocalVideo = hasVideo && !isRemoteVideo;
    final hasCoords = report.latitude != 0.0 || report.longitude != 0.0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AdminDialog(
          icon: Icons.shield_outlined,
          title:
              "Incident Dossier #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)}",
          subtitle: _formatDateTime(report.timestamp),
          maxWidth: 660,
          actions: [
            AdminButton(
              label: "Close",
              style: AdminButtonStyle.ghost,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            AdminButton(
              label: "Update Status / Notes",
              icon: Icons.edit,
              onPressed: () {
                Navigator.pop(dialogContext);
                _showEditReportDialog(context, report);
              },
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AdminPill(label: statusLabel, tone: statusTone),
              ),
              const SizedBox(height: 16),

              // Prominent On-Behalf Alert Callout (if filed for someone else)
              if (report.isReportingOnBehalf) ...[
                AdminInset(
                  tone: AdminTone.orange,
                  child: Row(
                    children: [
                      const AdminIconTile(
                        icon: Icons.people_alt,
                        tone: AdminTone.orange,
                        size: 42,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "REPORTED ON BEHALF (OFF-SITE FILING)",
                                  style: TextStyle(
                                    color: AdminColors.orangeLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                AdminPill(
                                  label: "ACTION REQUIRED",
                                  tone: AdminTone.orange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "On-Scene Victim: ${report.victimName?.isNotEmpty == true ? report.victimName! : 'Unspecified'}",
                              style: const TextStyle(
                                color: AdminColors.textStrong,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (report.victimPhone != null &&
                                report.victimPhone!.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                "Victim Phone: ${report.victimPhone!}",
                                style: const TextStyle(
                                  color: AdminColors.cyanText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (report.victimPhone != null &&
                          report.victimPhone!.trim().isNotEmpty) ...[
                        const SizedBox(width: 10),
                        AdminIconAction(
                          icon: Icons.phone_in_talk,
                          tooltip: "Call Victim Directly",
                          tone: AdminTone.cyan,
                          size: 40,
                          onPressed: () async {
                            final uri = Uri.parse(
                                "tel:${report.victimPhone!.replaceAll(' ', '').trim()}");
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Urgency & Category Banner
              AdminInset(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Wrap(
                  spacing: 28,
                  runSpacing: 14,
                  children: [
                    _DossierStat(
                      label: "CATEGORY",
                      child: Text(
                        report.category,
                        style: const TextStyle(
                          color: AdminColors.textStrong,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _DossierStat(
                      label: "TRIAGE URGENCY LEVEL",
                      child: AdminPill(
                        label: urgency,
                        tone: urgencyTone,
                        solid: urgencyTone == AdminTone.red,
                      ),
                    ),
                    _DossierStat(
                      label: "COMMUNITY CONFIRMED",
                      child: Text(
                        "${report.upvoteCount} citizen${report.upvoteCount == 1 ? '' : 's'}",
                        style: const TextStyle(
                          color: AdminColors.successText,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (report.estimatedResponseTime != null &&
                        report.estimatedResponseTime!.isNotEmpty)
                      _DossierStat(
                        label: "DISPATCH ETA",
                        labelColor: AdminColors.cyanSoft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 13,
                              color: AdminColors.cyanText,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                report.estimatedResponseTime!,
                                style: const TextStyle(
                                  color: AdminColors.cyanText,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Reporter Identity Box
              _buildSectionHeader(
                  Icons.person_pin, "REPORTER IDENTITY (LGU COMMAND VIEW)"),
              const SizedBox(height: 8),
              AdminInset(
                tone: report.isAnonymous ? AdminTone.orange : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AdminAvatar(
                              initial: (report.reporterName != null &&
                                      report.reporterName!.isNotEmpty)
                                  ? report.reporterName![0].toUpperCase()
                                  : "R",
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    (report.reporterName != null &&
                                            report.reporterName!.isNotEmpty)
                                        ? report.reporterName!
                                        : "Verified Resident",
                                    style: const TextStyle(
                                      color: AdminColors.textStrong,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (report.reporterEmail != null &&
                                      report.reporterEmail!.isNotEmpty)
                                    Text(
                                      report.reporterEmail!,
                                      style: const TextStyle(
                                        color: AdminColors.textLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (report.isAnonymous)
                          const AdminPill(
                            label: "Anonymous to Public",
                            tone: AdminTone.orange,
                            icon: Icons.lock_outline,
                          ),
                      ],
                    ),
                    if (report.isAnonymous) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AdminColors.orangeLight,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Citizen requested public anonymity. Identity is only visible to Command Center Dispatchers for verification and emergency response.",
                                style: TextStyle(
                                  color: AdminColors.amberLight,
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      "Account UID: ${report.reporterId}",
                      style: const TextStyle(
                        color: AdminColors.textHint,
                        fontSize: 10.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              if (report.isReportingOnBehalf) ...[
                const SizedBox(height: 16),
                _buildSectionHeader(Icons.people_alt,
                    "ON-SCENE AFFECTED PERSON (REPORTED ON BEHALF)"),
                const SizedBox(height: 8),
                AdminInset(
                  tone: AdminTone.orange,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person_pin_circle,
                            color: AdminColors.orangeLight,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              report.victimName?.isNotEmpty == true
                                  ? report.victimName!
                                  : "Unspecified Name",
                              style: const TextStyle(
                                color: AdminColors.textStrong,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const AdminPill(
                            label: "OFF-SITE FILING",
                            tone: AdminTone.orange,
                          ),
                        ],
                      ),
                      if (report.victimPhone != null &&
                          report.victimPhone!.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.phone,
                                  color: AdminColors.cyanText,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    "Contact: ${report.victimPhone!}",
                                    style: const TextStyle(
                                      color: AdminColors.cyanText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AdminButton(
                              label: "Call Victim",
                              icon: Icons.phone_in_talk,
                              style: AdminButtonStyle.cyan,
                              height: 36,
                              onPressed: () async {
                                final uri = Uri.parse(
                                    "tel:${report.victimPhone!.replaceAll(' ', '').trim()}");
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Location Information Box
              _buildSectionHeader(Icons.location_on,
                  "GEOLOCATION & REVERSE-GEOCODED STREET"),
              const SizedBox(height: 8),
              AdminInset(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.place,
                          color: AdminColors.primaryText,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fullAddress,
                            style: const TextStyle(
                              color: AdminColors.textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (hasCoords) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          Text(
                            "GPS: ${report.latitude.toStringAsFixed(6)}, ${report.longitude.toStringAsFixed(6)}",
                            style: const TextStyle(
                              color: AdminColors.textLight,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                          AdminButton(
                            label: "Open in Google Maps",
                            icon: Icons.map_outlined,
                            style: AdminButtonStyle.slate,
                            height: 36,
                            onPressed: () {
                              launchUrl(
                                Uri.parse(
                                    "https://www.google.com/maps/search/?api=1&query=${report.latitude},${report.longitude}"),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description
              _buildSectionHeader(Icons.description, "INCIDENT DESCRIPTION"),
              const SizedBox(height: 8),
              AdminInset(
                child: Text(
                  report.description.isNotEmpty
                      ? report.description
                      : "No description provided.",
                  style: const TextStyle(
                    color: AdminColors.textBody,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Multimedia Evidence (Photo & Video)
              _buildSectionHeader(Icons.perm_media, "MULTIMEDIA EVIDENCE"),
              const SizedBox(height: 8),
              if (!hasPhoto && !hasVideo)
                const AdminInset(
                  child: Row(
                    children: [
                      Icon(
                        Icons.attachment,
                        color: AdminColors.textHint,
                        size: 16,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "No photo or video attachments submitted.",
                          style: TextStyle(
                            color: AdminColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Photo preview
              if (isRemotePhoto) ...[
                AdminInset(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () {
                          InAppImageViewerDialog.show(
                            context,
                            imageUrl: report.photoUrl!,
                            title: "Photo Evidence • Incident #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)}",
                          );
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Tooltip(
                            message: "Click to open full resolution viewer",
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.network(
                                report.photoUrl!,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 220,
                                    color: AdminColors.well,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 140,
                                  color: AdminColors.well,
                                  padding: const EdgeInsets.all(12),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.broken_image_outlined,
                                          color: AdminColors.textLight,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          "Image preview blocked by browser security.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AdminColors.textLight,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.open_in_new,
                                            size: 14,
                                          ),
                                          label: const Text(
                                            "Open in Cloud Viewer",
                                            style: TextStyle(fontSize: 11),
                                          ),
                                          onPressed: () => launchUrl(
                                              Uri.parse(report.photoUrl!),
                                              mode: LaunchMode.externalApplication),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            const Text(
                              "Citizen Attached Photo",
                              style: TextStyle(
                                color: AdminColors.textLight,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AdminButton(
                              label: "View Full Resolution",
                              icon: Icons.fullscreen_rounded,
                              style: AdminButtonStyle.ghost,
                              height: 36,
                              onPressed: () {
                                InAppImageViewerDialog.show(
                                  context,
                                  imageUrl: report.photoUrl!,
                                  title: "Photo Evidence • Incident #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)}",
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ] else if (isLocalPhoto) ...[
                AdminInset(
                  tone: AdminTone.orange,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AdminIconTile(
                        icon: Icons.phonelink_erase_rounded,
                        tone: AdminTone.orange,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Evidence Stored Locally on Citizen Device",
                              style: TextStyle(
                                color: AdminColors.textStrong,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "This report was saved while the citizen was offline or before cloud upload finished. The photo was cached on the reporting phone.",
                              style: TextStyle(
                                color: AdminColors.textLight,
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Path: ${report.photoUrl}",
                              style: const TextStyle(
                                color: AdminColors.textHint,
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Video preview / action
              if (isRemoteVideo) ...[
                AdminInset(
                  tone: AdminTone.blue,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 14,
                    runSpacing: 12,
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AdminIconTile(
                            icon: Icons.videocam,
                            tone: AdminTone.blue,
                            size: 44,
                          ),
                          SizedBox(width: 14),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Video Evidence Attached",
                                  style: TextStyle(
                                    color: AdminColors.textStrong,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "High-definition video recording captured at scene",
                                  style: TextStyle(
                                    color: AdminColors.textLight,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AdminButton(
                            label: "Play In-App",
                            icon: Icons.play_circle_fill_rounded,
                            height: 40,
                            onPressed: () {
                              InAppEvidencePlayerDialog.show(
                                context,
                                videoUrl: report.videoUrl!,
                                title: "Video Evidence • Incident #${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)}",
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          AdminIconAction(
                            icon: Icons.open_in_new_rounded,
                            tooltip: "Open in External Tab",
                            size: 40,
                            onPressed: () => launchUrl(
                                Uri.parse(InAppEvidencePlayerDialog.formatPlayableVideoUrl(report.videoUrl!)),
                                mode: LaunchMode.externalApplication),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ] else if (isLocalVideo) ...[
                const AdminInset(
                  tone: AdminTone.orange,
                  child: Row(
                    children: [
                      Icon(
                        Icons.videocam_off_rounded,
                        color: AdminColors.orangeLight,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Video evidence was cached locally on citizen device and not uploaded to cloud.",
                          style: TextStyle(
                            color: AdminColors.textLight,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Dispatcher Notes
              if (report.dispatcherNotes != null &&
                  report.dispatcherNotes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildSectionHeader(
                    Icons.speaker_notes, "DISPATCHER & OPERATIONAL LOGS"),
                const SizedBox(height: 8),
                AdminInset(
                  tone: AdminTone.blue,
                  child: Text(
                    report.dispatcherNotes!,
                    style: const TextStyle(
                      color: AdminColors.textDark,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AdminColors.textHint),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              color: AdminColors.textHint,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

/// An uppercase table heading.
class _ColumnLabel extends StatelessWidget {
  const _ColumnLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    // Long headings wrap onto a second line, so every column fits at 1440px.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 112),
      child: Text(
        label.toUpperCase(),
        maxLines: 2,
        softWrap: true, // DataTable turns wrapping off for headings
        style: AdminTable.header.copyWith(height: 1.3),
      ),
    );
  }
}

/// A small labelled value in the dossier summary strip.
class _DossierStat extends StatelessWidget {
  const _DossierStat({
    required this.label,
    required this.child,
    this.labelColor = AdminColors.textHint,
  });

  final String label;
  final Widget child;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
