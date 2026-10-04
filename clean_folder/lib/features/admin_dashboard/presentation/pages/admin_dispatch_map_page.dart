import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/audit_log_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/core/presentation/widgets/in_app_evidence_player_dialog.dart';
import 'package:community_safety_app/core/presentation/widgets/in_app_image_viewer_dialog.dart';

class AdminDispatchMapPage extends StatefulWidget {
  const AdminDispatchMapPage({super.key});

  @override
  State<AdminDispatchMapPage> createState() => _AdminDispatchMapPageState();
}

class _AdminDispatchMapPageState extends State<AdminDispatchMapPage> {
  GoogleMapController? _mapController;

  // Selected filters
  String _selectedStatus = "All"; // All, Pending, In Progress, Solved
  bool _criticalOnly = false;
  String _activeSectorFilter = "All";

  // Selected incident for Dispatcher Drawer
  IncidentEntity? _selectedIncident;
  final TextEditingController _notesController = TextEditingController();
  bool _isSavingNotes = false;

  // Default coordinate: Barangay Moonwalk, Parañaque City
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(14.4851, 121.0116),
    zoom: 14.5,
  );

  static const String _darkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#0d1627"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#8ec3b9"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#060d1a"}]},
  {"featureType": "administrative.country", "elementType": "geometry.stroke", "stylers": [{"color": "#1e2d4a"}]},
  {"featureType": "administrative.land_parcel", "elementType": "labels.text.fill", "stylers": [{"color": "#64779e"}]},
  {"featureType": "administrative.province", "elementType": "geometry.stroke", "stylers": [{"color": "#1e2d4a"}]},
  {"featureType": "landscape.man_made", "elementType": "geometry.stroke", "stylers": [{"color": "#1e2d4a"}]},
  {"featureType": "landscape.natural", "elementType": "geometry", "stylers": [{"color": "#08101e"}]},
  {"featureType": "poi", "elementType": "geometry", "stylers": [{"color": "#0f1c32"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#6f88b0"}]},
  {"featureType": "poi.park", "elementType": "geometry.fill", "stylers": [{"color": "#0a1a24"}]},
  {"featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [{"color": "#3C7680"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#18263e"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#111c2f"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#98a6be"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#23395b"}]},
  {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#17263c"}]},
  {"featureType": "road.highway", "elementType": "labels.text.fill", "stylers": [{"color": "#b0d5ce"}]},
  {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#182740"}]},
  {"featureType": "transit.station", "elementType": "labels.text.fill", "stylers": [{"color": "#6f88b0"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#061324"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#3d648f"}]}
]
''';

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onIncidentSelected(IncidentEntity inc) {
    setState(() {
      _selectedIncident = inc;
      _notesController.text = inc.dispatcherNotes ?? '';
    });

    // Center camera smoothly on selected marker
    if (_mapController != null && inc.latitude != 0.0 && inc.longitude != 0.0) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(inc.latitude, inc.longitude)),
      );
    }
  }

  void _closeDrawer() {
    setState(() {
      _selectedIncident = null;
      _notesController.clear();
    });
  }

  // ── Option A: Dynamic Hotspot Bounding Box Camera Zoom ─────────────────
  void _zoomToSector(String sector, List<IncidentEntity> incidents) {
    setState(() => _activeSectorFilter = sector);

    if (sector == "All") {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(_initialPosition),
      );
      return;
    }

    final sectorIncidents = incidents.where((i) {
      final s = BarangaySectorHelper.normalizeSector(i.areaSector, i.resolvedAddress);
      return s == sector && i.latitude != 0.0 && i.longitude != 0.0;
    }).toList();

    if (sectorIncidents.isEmpty || _mapController == null) return;

    if (sectorIncidents.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(sectorIncidents.first.latitude, sectorIncidents.first.longitude),
          16.5,
        ),
      );
      return;
    }

    double minLat = sectorIncidents.first.latitude;
    double maxLat = sectorIncidents.first.latitude;
    double minLng = sectorIncidents.first.longitude;
    double maxLng = sectorIncidents.first.longitude;

    for (final inc in sectorIncidents) {
      minLat = min(minLat, inc.latitude);
      maxLat = max(maxLat, inc.latitude);
      minLng = min(minLng, inc.longitude);
      maxLng = max(maxLng, inc.longitude);
    }

    // Add slight padding to bounds
    final bounds = LatLngBounds(
      southwest: LatLng(minLat - 0.0015, minLng - 0.0015),
      northeast: LatLng(maxLat + 0.0015, maxLng + 0.0015),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60.0),
    );
  }

  // ── Status & Dispatch Updates ──────────────────────────────────────────
  Future<void> _updateStatus(String newStatus, {String? eta}) async {
    if (_selectedIncident == null) return;
    final inc = _selectedIncident!;
    final notes = _notesController.text.trim();

    context.read<IncidentBloc>().add(
          UpdateIncidentStatusRequested(
            inc.id,
            newStatus,
            dispatcherNotes: notes.isNotEmpty ? notes : inc.dispatcherNotes,
            estimatedResponseTime: eta ?? (newStatus == 'resolved' ? null : inc.estimatedResponseTime),
          ),
        );

    // Audit log
    try {
      final admin = FirebaseAuth.instance.currentUser;
      final etaSnippet = (eta != null && eta.trim().isNotEmpty) ? " | ETA: $eta" : "";
      sl<AuditLogRemoteDataSource>().recordLog(
        actionType: 'STATUS_UPDATE',
        details: 'Map Dispatch: Changed case status to "$newStatus"$etaSnippet',
        targetId: inc.id,
        adminName: admin?.displayName ?? 'Desk Officer',
        adminEmail: admin?.email,
      );
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Case ${inc.id.substring(0, min(8, inc.id.length))} updated to $newStatus!"),
        backgroundColor: AppColors.solved,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _selectedIncident = null;
    });
  }

  Future<void> _showDispatchEtaDialog(BuildContext context, IncidentEntity inc) async {
    final etaController = TextEditingController(text: inc.estimatedResponseTime ?? "10-15 mins");
    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1627),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFF1E2D4A)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.timer_outlined, color: Color(0xFF00E5FF), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Dispatch Patrol • Set ETA",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dispatching responders to ${inc.areaSector ?? 'Moonwalk'} for ${inc.category}. The citizen will be notified of this estimated arrival time.",
                      style: const TextStyle(color: Color(0xFF7B8DB0), fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "ESTIMATED ARRIVAL TIME (ETA)",
                      style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        "5-10 mins",
                        "10-15 mins",
                        "15-20 mins",
                        "20-30 mins",
                      ].map((chip) {
                        final isSelected = etaController.text == chip;
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              etaController.text = chip;
                            });
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00E5FF).withValues(alpha: 0.25)
                                  : const Color(0xFF060D1A),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00E5FF)
                                      : const Color(0xFF1E2D4A)),
                            ),
                            child: Text(
                              chip,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFF00E5FF)
                                    : const Color(0xFF7B8DB0),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: etaController,
                      style: const TextStyle(color: Color(0xFFE8F0FE), fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Or custom (e.g. 7 mins)...",
                        hintStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF060D1A),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF1E2D4A))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF1E2D4A))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00E5FF))),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("Cancel", style: TextStyle(color: Color(0xFF7B8DB0))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: const Color(0xFF060D1A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final eta = etaController.text.trim();
                    Navigator.pop(dialogCtx);
                    _updateStatus("in_progress", eta: eta.isNotEmpty ? eta : null);
                  },
                  child: const Text("Confirm & Dispatch", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveNotesOnly() async {
    if (_selectedIncident == null) return;
    final inc = _selectedIncident!;
    final notes = _notesController.text.trim();
    if (notes.isEmpty) return;

    setState(() => _isSavingNotes = true);

    context.read<IncidentBloc>().add(
          UpdateIncidentStatusRequested(
            inc.id,
            inc.status,
            dispatcherNotes: notes,
          ),
        );

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() => _isSavingNotes = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Dispatcher remarks saved!"),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Marker Pin Color Triage ────────────────────────────────────────────
  double _getMarkerHue(IncidentEntity inc) {
    final prio = (inc.urgencyStatus ?? '').toLowerCase();
    if (prio == 'critical' || prio == 'high' || inc.upvoteCount >= 3) {
      return BitmapDescriptor.hueRed; // 🚨 High / Critical Priority
    }
    if (inc.isSolved) {
      return BitmapDescriptor.hueGreen; // 🟢 Solved
    }
    if (inc.isInProgress) {
      return BitmapDescriptor.hueAzure; // 🔵 In Progress / Dispatched
    }
    return BitmapDescriptor.hueOrange; // 🟡 Pending
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidentBloc, IncidentState>(
      builder: (context, state) {
        final allIncidents = state is IncidentLoaded ? state.incidents : <IncidentEntity>[];

        // 1. Group active sectors for Option A Hotspot Chips
        final Map<String, int> sectorCounts = {};
        for (final inc in allIncidents) {
          if (inc.latitude != 0.0 && inc.longitude != 0.0) {
            final sector = BarangaySectorHelper.normalizeSector(inc.areaSector, inc.resolvedAddress);
            sectorCounts[sector] = (sectorCounts[sector] ?? 0) + 1;
          }
        }
        final sortedSectors = sectorCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // 2. Filter incidents for display on map
        final filteredIncidents = allIncidents.where((inc) {
          // Exclude invalid coordinates
          if (inc.latitude == 0.0 || inc.longitude == 0.0) return false;

          // Status filter
          if (_selectedStatus == "Pending" && !inc.isPending) return false;
          if (_selectedStatus == "In Progress" && !inc.isInProgress) return false;
          if (_selectedStatus == "Solved" && !inc.isSolved) return false;

          // Urgency filter
          if (_criticalOnly) {
            final prio = (inc.urgencyStatus ?? '').toLowerCase();
            final isCrit = prio == 'critical' || prio == 'high' || inc.upvoteCount >= 3;
            if (!isCrit) return false;
          }

          // Sector filter
          if (_activeSectorFilter != "All") {
            final sec = BarangaySectorHelper.normalizeSector(inc.areaSector, inc.resolvedAddress);
            if (sec != _activeSectorFilter) return false;
          }

          return true;
        }).toList();

        // 3. Build Map Markers
        final markers = filteredIncidents.map((inc) {
          return Marker(
            markerId: MarkerId(inc.id),
            position: LatLng(inc.latitude, inc.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(inc)),
            infoWindow: InfoWindow(
              title: inc.category,
              snippet: "${inc.resolvedAddress ?? 'Barangay Moonwalk'} (${inc.status.toUpperCase()})",
              onTap: () => _onIncidentSelected(inc),
            ),
            onTap: () => _onIncidentSelected(inc),
          );
        }).toSet();

        return Scaffold(
          backgroundColor: const Color(0xFF0D1627),
          body: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // ── Google Map Basemap ──────────────────────────────────────
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('broadcasts')
                          .where('isActive', isEqualTo: true)
                          .snapshots(),
                      builder: (context, broadcastSnapshot) {
                        final Set<Circle> circles = {};

                        // Draw glowing red circle overlays for active emergency sirens
                        if (broadcastSnapshot.hasData) {
                          for (final doc in broadcastSnapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final targetSector = data['targetSector'] as String? ?? 'All';

                            // Find incidents in this sector to center the alert circle
                            final targetIncidents = allIncidents.where((i) {
                              if (targetSector == 'All') return true;
                              final s = BarangaySectorHelper.normalizeSector(i.areaSector, i.resolvedAddress);
                              return s.toLowerCase().contains(targetSector.toLowerCase());
                            }).toList();

                            if (targetIncidents.isNotEmpty) {
                              circles.add(
                                Circle(
                                  circleId: CircleId(doc.id),
                                  center: LatLng(
                                    targetIncidents.first.latitude,
                                    targetIncidents.first.longitude,
                                  ),
                                  radius: 400, // 400 meter siren radius
                                  fillColor: const Color(0xFFFF3B30).withValues(alpha: 0.18),
                                  strokeColor: const Color(0xFFFF3B30).withValues(alpha: 0.8),
                                  strokeWidth: 2,
                                ),
                              );
                            }
                          }
                        }

                        return GoogleMap(
                          initialCameraPosition: _initialPosition,
                          style: _darkMapStyle,
                          markers: markers,
                          circles: circles,
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          onTap: (_) {
                            if (_selectedIncident != null) _closeDrawer();
                          },
                        );
                      },
                    ),

                    // ── Top Bar: Tactical Filters & Dynamic Hotspot Chips ───────
                    Positioned(
                      top: 18,
                      left: 18,
                      right: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Filter Bar Card
                          _buildTacticalFilterCard(filteredIncidents.length, allIncidents),
                          const SizedBox(height: 10),

                          // Option A: Dynamic Active Hotspot Chips Row
                          if (sortedSectors.isNotEmpty)
                            _buildDynamicHotspotChips(sortedSectors, allIncidents),
                        ],
                      ),
                    ),

                    // ── Floating Zoom / Recenter Buttons (Bottom Left) ──────────
                    Positioned(
                      bottom: 24,
                      left: 24,
                      child: Column(
                        children: [
                          _mapControlButton(
                            Icons.add,
                            () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                            "Zoom In",
                          ),
                          const SizedBox(height: 8),
                          _mapControlButton(
                            Icons.remove,
                            () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                            "Zoom Out",
                          ),
                          const SizedBox(height: 8),
                          _mapControlButton(
                            Icons.my_location_rounded,
                            () => _zoomToSector("All", allIncidents),
                            "Center Moonwalk",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Dispatcher Action Drawer (Side-by-Side Panel) ───────────
              if (_selectedIncident != null)
                SizedBox(
                  width: 380,
                  child: _buildDispatcherDrawer(_selectedIncident!),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Tactical Filter Bar Card ───────────────────────────────────────────
  Widget _buildTacticalFilterCard(int visibleCount, List<IncidentEntity> allIncidents) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1627).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E2D4A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Live Map Indicator & Count
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF30D158),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "$visibleCount ON MAP",
                style: const TextStyle(
                  color: Color(0xFFE8F0FE),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
            child: VerticalDivider(color: Color(0xFF1E2D4A), thickness: 1.2),
          ),

          // Status Filter Chips
          _statusFilterChip("All"),
          _statusFilterChip("Pending", const Color(0xFFFF9F0A)),
          _statusFilterChip("In Progress", const Color(0xFF00E5FF)),
          _statusFilterChip("Solved", const Color(0xFF30D158)),

          const SizedBox(
            height: 18,
            child: VerticalDivider(color: Color(0xFF1E2D4A), thickness: 1.2),
          ),

          // 🚨 Critical Only Toggle Button
          GestureDetector(
            onTap: () => setState(() => _criticalOnly = !_criticalOnly),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _criticalOnly
                    ? const Color(0xFFFF3B30).withValues(alpha: 0.25)
                    : const Color(0xFF131F37),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _criticalOnly
                      ? const Color(0xFFFF3B30)
                      : const Color(0xFF1E2D4A),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: _criticalOnly
                        ? const Color(0xFFFF3B30)
                        : const Color(0xFF7B8DB0),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Critical Only",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _criticalOnly
                          ? const Color(0xFFFF3B30)
                          : const Color(0xFFB0C4DE),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusFilterChip(String label, [Color? activeColor]) {
    final isSelected = _selectedStatus == label;
    final color = activeColor ?? const Color(0xFF0A84FF);

    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF1E2D4A),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? color : const Color(0xFF7B8DB0),
          ),
        ),
      ),
    );
  }

  // ── Option A: Dynamic Active Hotspot Chips Row ─────────────────────────
  Widget _buildDynamicHotspotChips(
    List<MapEntry<String, int>> sortedSectors,
    List<IncidentEntity> allIncidents,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Reset to All Moonwalk
          _hotspotChip(
            title: "🌐 All Moonwalk",
            count: allIncidents.length,
            isSelected: _activeSectorFilter == "All",
            onTap: () => _zoomToSector("All", allIncidents),
          ),
          const SizedBox(width: 8),

          // Dynamic chips derived from live incidents
          ...sortedSectors.map((entry) {
            final isSelected = _activeSectorFilter == entry.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _hotspotChip(
                title: "🎯 ${entry.key}",
                count: entry.value,
                isSelected: isSelected,
                onTap: () => _zoomToSector(entry.key, allIncidents),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _hotspotChip({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00E5FF).withValues(alpha: 0.22)
              : const Color(0xFF0D1627).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00E5FF)
                : const Color(0xFF1E2D4A),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF00E5FF) : const Color(0xFFE8F0FE),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
                    : const Color(0xFF1E2D4A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$count",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF7B8DB0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dispatcher Action Drawer (Pin Clicked) ─────────────────────────────
  Widget _buildDispatcherDrawer(IncidentEntity inc) {
    final sector = BarangaySectorHelper.normalizeSector(inc.areaSector, inc.resolvedAddress);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1627),
        border: const Border(
          left: BorderSide(color: Color(0xFF1E2D4A), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(-6, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF1E2D4A)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.radar_rounded,
                          color: Color(0xFF0A84FF),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "TACTICAL DISPATCH DESK",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE8F0FE),
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            "Case #${inc.id.substring(0, min(8, inc.id.length))}",
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF7B8DB0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF7B8DB0)),
                    onPressed: _closeDrawer,
                  ),
                ],
              ),
            ),

            // Scrollable Case Details
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status & Urgency Badges
                    Row(
                      children: [
                        _drawerBadge(
                          inc.status.toUpperCase(),
                          inc.isSolved
                              ? const Color(0xFF30D158)
                              : (inc.isInProgress
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFFFF9F0A)),
                        ),
                        const SizedBox(width: 8),
                        _drawerBadge(
                          (inc.urgencyStatus ?? "NORMAL").toUpperCase(),
                          const Color(0xFFFF3B30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Incident Category Title
                    Text(
                      inc.category,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE8F0FE),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      inc.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB0C4DE),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Location & Address Block ─────────────────────────
                    _drawerSectionHeader(Icons.location_on_outlined, "Location & Sector"),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131F37),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E2D4A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inc.resolvedAddress ?? "Barangay Moonwalk",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE8F0FE),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Sector: $sector",
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF00E5FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // 1-Tap Google Maps External Directions Link
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final url = Uri.parse(
                                  "https://www.google.com/maps/search/?api=1&query=${inc.latitude},${inc.longitude}",
                                );
                                launchUrl(url, mode: LaunchMode.externalApplication);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF0A84FF)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              icon: const Icon(Icons.navigation_rounded, size: 15, color: Color(0xFF0A84FF)),
                              label: const Text(
                                "Navigate in Google Maps",
                                style: TextStyle(color: Color(0xFF0A84FF), fontSize: 11.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Complainant & Emergency Contact Dossier ──────────
                    _drawerSectionHeader(Icons.contact_phone_outlined, "Citizen & Emergency Dossier"),
                    const SizedBox(height: 8),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(inc.reporterId).get(),
                      builder: (context, userSnap) {
                        final userData = userSnap.data?.data() as Map<String, dynamic>?;
                        final contactPerson = (userData?['emergencyContactName'] ?? userData?['emergencyContactPerson']) as String?;
                        final contactPhone = (userData?['emergencyContactNumber'] ?? userData?['emergencyContactPhone']) as String?;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131F37),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1E2D4A)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (inc.isReportingOnBehalf) ...[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9500).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFF9500).withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.people_alt_rounded, size: 12, color: Color(0xFFFF9500)),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          "REPORTED ON BEHALF: ${inc.victimName ?? 'Relative'}${inc.victimPhone != null && inc.victimPhone!.isNotEmpty ? ' • ${inc.victimPhone}' : ''}",
                                          style: const TextStyle(
                                            color: Color(0xFFFF9500),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (inc.estimatedResponseTime != null &&
                                  inc.estimatedResponseTime!.isNotEmpty) ...[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF00E5FF)),
                                      const SizedBox(width: 4),
                                      Text(
                                        "DISPATCH ETA: ${inc.estimatedResponseTime!}",
                                        style: const TextStyle(
                                          color: Color(0xFF00E5FF),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              Text(
                                inc.isAnonymous ? "Anonymous Citizen" : (inc.reporterName ?? "Resident"),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE8F0FE),
                                ),
                              ),
                              if (!inc.isAnonymous && inc.reporterEmail != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  inc.reporterEmail!,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF7B8DB0)),
                                ),
                              ],
                              const Divider(color: Color(0xFF1E2D4A), height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.emergency_outlined, size: 15, color: Color(0xFFFF5252)),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Emergency Contact: ",
                                    style: TextStyle(fontSize: 11, color: Color(0xFF7B8DB0), fontWeight: FontWeight.w600),
                                  ),
                                  Expanded(
                                    child: Text(
                                      contactPerson != null && contactPerson.isNotEmpty
                                          ? "$contactPerson ($contactPhone)"
                                          : "Not registered",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFF5252),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    // ── Photo Evidence Preview ───────────────────────────
                    if (inc.photoUrl != null && inc.photoUrl!.isNotEmpty) ...[
                      _drawerSectionHeader(Icons.image_outlined, "Photo Evidence"),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          InAppImageViewerDialog.show(
                            context,
                            imageUrl: inc.photoUrl!,
                            title: "Incident #${inc.id.substring(0, min(8, inc.id.length))} Photo Evidence",
                          );
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Tooltip(
                            message: "Click to open full resolution viewer",
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  Image.network(
                                    inc.photoUrl!,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                  ),
                                  Positioned(
                                    right: 8,
                                    bottom: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.zoom_in, color: Colors.white, size: 14),
                                          SizedBox(width: 4),
                                          Text("Zoom", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // ── Video Evidence Preview ───────────────────────────
                    if (inc.videoUrl != null && inc.videoUrl!.isNotEmpty) ...[
                      _drawerSectionHeader(Icons.videocam_outlined, "Video Evidence"),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF060D1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF0A84FF).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.videocam_rounded, color: Color(0xFF0A84FF), size: 22),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Video Recording Attached",
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A84FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.play_arrow_rounded, size: 16),
                              label: const Text("Play In-App", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                InAppEvidencePlayerDialog.show(
                                  context,
                                  videoUrl: inc.videoUrl!,
                                  title: "Incident #${inc.id.substring(0, min(8, inc.id.length))} Video Evidence",
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // ── Dispatcher Remarks Field ─────────────────────────
                    _drawerSectionHeader(Icons.note_alt_outlined, "Dispatcher Remarks"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 12, color: Color(0xFFE8F0FE)),
                      decoration: InputDecoration(
                        hintText: "Enter Tanod patrol remarks, response logs...",
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF5A6E8C)),
                        filled: true,
                        fillColor: const Color(0xFF131F37),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E2D4A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E2D4A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _isSavingNotes ? null : _saveNotesOnly,
                        icon: _isSavingNotes
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF00E5FF)),
                              )
                            : const Icon(Icons.check, size: 14, color: Color(0xFF00E5FF)),
                        label: const Text(
                          "Save Remarks",
                          style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Fixed Bottom Dispatch Action Buttons ─────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFF0D1627),
                border: Border(top: BorderSide(color: Color(0xFF1E2D4A))),
              ),
              child: Column(
                children: [
                  if (inc.isPending) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => _showDispatchEtaDialog(context, inc),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: const Color(0xFF060D1A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: const Text(
                          "Dispatch Patrol (In Progress)",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                    ),
                  ] else if (inc.isInProgress) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus("resolved"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF30D158),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text(
                          "Mark Incident Solved",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => _showDispatchEtaDialog(context, inc),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF9F0A)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.replay_rounded, size: 16, color: Color(0xFFFF9F0A)),
                        label: const Text(
                          "Re-Open Incident",
                          style: TextStyle(color: Color(0xFFFF9F0A), fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _drawerSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF00E5FF)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFFE8F0FE),
          ),
        ),
      ],
    );
  }

  Widget _mapControlButton(IconData icon, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1627).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E2D4A)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF00E5FF), size: 18),
        ),
      ),
    );
  }
}
