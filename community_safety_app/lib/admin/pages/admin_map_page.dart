import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/admin_data_service.dart';
import '../models/incident_report.dart';
import '../../widgets/custom_3d_button.dart';
import '../../widgets/compact_map_legend.dart';
import '../../utils/marker_generator.dart';
import '../../services/mock_database_service.dart';

class AdminMapPage extends StatefulWidget {
  final LatLng? focusLocation;

  const AdminMapPage({
    super.key,
    this.focusLocation,
  });

  @override
  State<AdminMapPage> createState() => _AdminMapPageState();
}

class _AdminMapPageState extends State<AdminMapPage> {
  GoogleMapController? _mapController;
  final LatLng _defaultCenter = const LatLng(14.4793, 121.0198); // Moonwalk / Manila default


  Timer? _autoRefreshTimer;

  String _statusFilter = "All";
  String _categoryFilter = "All Categories";

  @override
  void initState() {
    super.initState();
    // Auto-refresh Admin Map data every 4 seconds to reflect newly submitted incidents automatically
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        MockDatabaseService().syncWithBackend();
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  final List<String> _statusOptions = [
    "All",
    "Pending",
    "In Progress",
    "Solved",
    "Spam",
  ];

  final List<String> _categoryOptions = [
    "All Categories",
    "Fire Incident",
    "Theft / Robbery",
    "Medical Emergency",
    "Violence / Physical Fight",
    "Road Accident",
    "Suspicious Activity",
    "Flood / Calamity",
    "Lost Item / Missing Person",
    "Noise Complaint",
    "Other Emergency",
  ];

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
      case 'severe':
        return const Color(0xFFFF334B);
      case 'high':
        return const Color(0xFFFF9800);
      case 'medium':
      case 'moderate':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF0088FF);
    }
  }

  Future<Set<Marker>> _buildAdminCustomMarkers(
    List<IncidentReport> reports,
    AdminDataService dataService,
  ) async {
    final Set<Marker> markers = {};

    for (final report in reports) {
      if (report.latitude == null || report.longitude == null) continue;
      final icon = await MarkerGenerator.getIncidentMarker(
        category: report.incidentType,
        status: report.status,
      );

      markers.add(
        Marker(
          markerId: MarkerId(report.id),
          position: LatLng(report.latitude!, report.longitude!),
          icon: icon,
          infoWindow: InfoWindow(
            title: report.incidentType,
            snippet: "${report.statusLabel} • ${report.location}",
          ),
          onTap: () => _showAdminIncidentDetails(report, dataService),
        ),
      );
    }

    return markers;
  }

  void _showAdminIncidentDetails(IncidentReport report, AdminDataService dataService) {
    final statusColor = MarkerGenerator.getColorForStatus(report.status);
    final categoryIcon = MarkerGenerator.getCategoryIcon(report.incidentType);
    final urgencyColor = _getUrgencyColor(report.urgencyLevel);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2D4A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
                        ),
                        child: Icon(
                          categoryIcon,
                          color: statusColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.incidentType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "ID: ${report.id} • Reported by: ${report.reporterName}",
                              style: const TextStyle(
                                color: Color(0xFF8E9BAE),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          report.statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF060D1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E2D4A)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.location_on, "Location", report.location),
                        if (report.latitude != null && report.longitude != null) ...[
                          const Divider(color: Color(0xFF1E2D4A), height: 16),
                          _buildDetailRow(
                            Icons.my_location,
                            "GPS Coordinates",
                            "${report.latitude!.toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}",
                          ),
                        ],
                        const Divider(color: Color(0xFF1E2D4A), height: 16),
                        Row(
                          children: [
                            const Icon(Icons.warning_rounded, size: 16, color: Color(0xFF0A84FF)),
                            const SizedBox(width: 10),
                            const Text(
                              "Urgency Level:",
                              style: TextStyle(
                                color: Color(0xFF8E9BAE),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: urgencyColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: urgencyColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                report.urgencyLevel,
                                style: TextStyle(
                                  color: urgencyColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFF1E2D4A), height: 16),
                        _buildDetailRow(Icons.person_outline, "Reporter Identity", report.reporterName),
                        const Divider(color: Color(0xFF1E2D4A), height: 16),
                        _buildDetailRow(
                          Icons.access_time,
                          "Reported Date",
                          "${report.date.day}/${report.date.month}/${report.date.year} ${report.date.hour}:${report.date.minute.toString().padLeft(2, '0')}",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Description",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.description,
                    style: const TextStyle(
                      color: Color(0xFF8E9BAE),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Update Incident Status:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statusActionButton(ctx, report, IncidentStatus.pending, dataService, setModalState),
                      _statusActionButton(ctx, report, IncidentStatus.inProgress, dataService, setModalState),
                      _statusActionButton(ctx, report, IncidentStatus.solved, dataService, setModalState),
                      _statusActionButton(ctx, report, IncidentStatus.spam, dataService, setModalState),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Custom3dButton(
                    icon: Icons.check,
                    text: "Close Modal",
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusActionButton(
    BuildContext ctx,
    IncidentReport report,
    IncidentStatus targetStatus,
    AdminDataService dataService,
    StateSetter setModalState,
  ) {
    final bool isSelected = report.status == targetStatus;
    final color = MarkerGenerator.getColorForStatus(targetStatus);

    return InkWell(
      onTap: () {
        dataService.updateReportStatus(report.id, targetStatus);
        setModalState(() {});
        setState(() {});
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          targetStatus.name.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0A84FF)),
        const SizedBox(width: 10),
        Text(
          "$title:",
          style: const TextStyle(
            color: Color(0xFF8E9BAE),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataService = AdminDataService();

    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final allReports = dataService.reports;
        final totalCount = allReports.length;

        // Ignore reports with NULL coordinates
        final validReports = allReports.where((r) => r.latitude != null && r.longitude != null).toList();
        final unmappedCount = totalCount - validReports.length;

        // Apply Status and Category filters
        final filteredReports = validReports.where((r) {
          final matchesStatus = _statusFilter == "All" || r.statusLabel == _statusFilter;
          final matchesCategory = _categoryFilter == "All Categories" ||
              r.incidentType.toLowerCase() == _categoryFilter.toLowerCase();
          return matchesStatus && matchesCategory;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title and statistics badge
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Admin Incident Command Map",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Visualizing ${filteredReports.length} of ${validReports.length} mapped incidents ($unmappedCount missing GPS coordinates)",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8E9BAE),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter Controls Toolbar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1628),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2D4A)),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Status Filter Dropdown
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_alt_outlined, color: Color(0xFF0A84FF), size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          "Status:",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _statusFilter,
                          dropdownColor: const Color(0xFF0A1628),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          underline: Container(),
                          items: _statusOptions.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _statusFilter = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // Category Filter Dropdown
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.category_outlined, color: Color(0xFF0A84FF), size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          "Category:",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _categoryFilter,
                          dropdownColor: const Color(0xFF0A1628),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          underline: Container(),
                          items: _categoryOptions.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _categoryFilter = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    const Spacer(),

                    Text(
                      "${filteredReports.length} Pins Active",
                      style: const TextStyle(
                        color: Color(0xFF0A84FF),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Interactive Google Map View Container
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FutureBuilder<Set<Marker>>(
                    future: _buildAdminCustomMarkers(filteredReports, dataService),
                    builder: (context, snapshot) {
                      final markers = snapshot.data ?? {};

                      return Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: widget.focusLocation ?? _defaultCenter,
                              zoom: widget.focusLocation != null ? 16.0 : 13.0,
                            ),
                            onMapCreated: (controller) {
                              _mapController = controller;
                              if (widget.focusLocation != null) {
                                controller.animateCamera(
                                  CameraUpdate.newLatLngZoom(widget.focusLocation!, 16.0),
                                );
                              }
                            },

                            markers: markers,
                            myLocationEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            compassEnabled: true,
                          ),

                          // Compact Map Legend Overlay (Top Left of Map view)
                          const Positioned(
                            top: 14,
                            left: 14,
                            child: CompactMapLegend(showUserLocation: false),
                          ),

                          // Map Control Action Buttons
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FloatingActionButton.small(
                                  heroTag: "admin_zoom_in",
                                  backgroundColor: const Color(0xFF0A1628),
                                  foregroundColor: const Color(0xFF0A84FF),
                                  onPressed: () {
                                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                                  },
                                  child: const Icon(Icons.add),
                                ),
                                const SizedBox(height: 8),
                                FloatingActionButton.small(
                                  heroTag: "admin_zoom_out",
                                  backgroundColor: const Color(0xFF0A1628),
                                  foregroundColor: const Color(0xFF0A84FF),
                                  onPressed: () {
                                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                                  },
                                  child: const Icon(Icons.remove),
                                ),
                                const SizedBox(height: 8),
                                FloatingActionButton.small(
                                  heroTag: "admin_recenter_center",
                                  backgroundColor: const Color(0xFF0A84FF),
                                  foregroundColor: Colors.white,
                                  onPressed: () {
                                    if (filteredReports.isNotEmpty &&
                                        filteredReports.first.latitude != null &&
                                        filteredReports.first.longitude != null) {
                                      _mapController?.animateCamera(
                                        CameraUpdate.newLatLngZoom(
                                          LatLng(filteredReports.first.latitude!, filteredReports.first.longitude!),
                                          14.0,
                                        ),
                                      );
                                    } else {
                                      _mapController?.animateCamera(
                                        CameraUpdate.newLatLngZoom(_defaultCenter, 13.0),
                                      );
                                    }
                                  },
                                  child: const Icon(Icons.center_focus_strong),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
