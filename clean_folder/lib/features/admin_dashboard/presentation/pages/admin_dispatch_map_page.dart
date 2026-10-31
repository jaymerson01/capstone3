import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';

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
        backgroundColor: AdminColors.success,
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
            return AdminDialog(
              title: "Dispatch Patrol • Set ETA",
              icon: Icons.timer_outlined,
              tone: AdminTone.cyan,
              maxWidth: 440,
              actions: [
                AdminButton(
                  label: "Cancel",
                  style: AdminButtonStyle.ghost,
                  onPressed: () => Navigator.pop(dialogCtx),
                ),
                AdminButton(
                  label: "Confirm & Dispatch",
                  onPressed: () {
                    final eta = etaController.text.trim();
                    Navigator.pop(dialogCtx);
                    _updateStatus("in_progress", eta: eta.isNotEmpty ? eta : null);
                  },
                ),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dispatching responders to ${inc.areaSector ?? 'Moonwalk'} for ${inc.category}. The citizen will be notified of this estimated arrival time.",
                    style: const TextStyle(
                      color: AdminColors.textSoft,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const AdminFieldLabel("ESTIMATED ARRIVAL TIME (ETA)"),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      "5-10 mins",
                      "10-15 mins",
                      "15-20 mins",
                      "20-30 mins",
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: etaController,
                    style: adminInputText,
                    cursorColor: AdminColors.cyan,
                    decoration: adminInputDecoration(
                      hint: "Or custom (e.g. 7 mins)...",
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
        backgroundColor: AdminColors.primary,
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
          backgroundColor: Colors.transparent,
          body: LayoutBuilder(
            builder: (context, constraints) {
              // The dispatch desk sits beside the map, or under it on phones.
              // The map stays the first child of the same Flex either way, so
              // opening the desk or resizing never rebuilds it.
              final bool deskBeside = constraints.maxWidth >= 700;
              final bool compact = constraints.maxWidth < 1000;

              return Padding(
                padding: compact
                    ? const EdgeInsets.all(16)
                    : const EdgeInsets.fromLTRB(28, 22, 28, 28),
                child: Flex(
                  direction: deskBeside ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _MapFrame(
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
                                          fillColor: AdminColors.danger.withValues(alpha: 0.18),
                                          strokeColor: AdminColors.danger.withValues(alpha: 0.8),
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
                              top: 14,
                              left: 14,
                              right: 72,
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

                            // ── Floating Zoom / Recenter Buttons (Top Right) ────────────
                            Positioned(
                              top: 14,
                              right: 14,
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
                                    tone: AdminTone.cyan,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Dispatcher Action Drawer (Side-by-Side Panel) ───────────
                    if (_selectedIncident != null) ...[
                      SizedBox.square(dimension: compact ? 14 : 18),
                      if (deskBeside)
                        SizedBox(
                          width: compact ? 340 : 380,
                          child: _buildDispatcherDrawer(_selectedIncident!),
                        )
                      else
                        Expanded(
                          flex: 3,
                          child: _buildDispatcherDrawer(_selectedIncident!),
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Tactical Filter Bar Card ───────────────────────────────────────────
  Widget _buildTacticalFilterCard(int visibleCount, List<IncidentEntity> allIncidents) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Live Map Indicator & Count
        _MapPill(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AdminColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AdminColors.success.withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "$visibleCount ON MAP",
                style: const TextStyle(
                  color: AdminColors.textStrong,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),

        // Status Filter Chips
        _statusFilterChip("All"),
        _statusFilterChip("Pending", AdminColors.orange),
        _statusFilterChip("In Progress", AdminColors.blue),
        _statusFilterChip("Solved", AdminColors.success),

        // 🚨 Critical Only Toggle Button
        _MapPill(
          onTap: () => setState(() => _criticalOnly = !_criticalOnly),
          selected: _criticalOnly,
          gradient: _criticalOnly ? AdminColors.sirenGradient : null,
          edge: AdminColors.dangerSoft.withValues(alpha: 0.45),
          glow: _criticalOnly ? AdminColors.critical : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 15,
                color: _criticalOnly ? Colors.white : AdminColors.dangerSoft,
              ),
              const SizedBox(width: 6),
              Text(
                "Critical Only",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: _criticalOnly ? FontWeight.w800 : FontWeight.w700,
                  color: _criticalOnly ? Colors.white : AdminColors.dangerPale,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusFilterChip(String label, [Color? activeColor]) {
    final isSelected = _selectedStatus == label;

    return _MapPill(
      onTap: () => setState(() => _selectedStatus = label),
      selected: isSelected,
      gradient: isSelected ? AdminColors.primaryGradient : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A dot in the pin colour for this status, as a map legend.
          if (activeColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : activeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              color: isSelected ? Colors.white : AdminColors.textSoft,
            ),
          ),
        ],
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
          SizedBox(width: 8),

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
    return _MapPill(
      onTap: onTap,
      selected: isSelected,
      edge: isSelected ? AdminColors.cyan.withValues(alpha: 0.55) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              color: isSelected ? AdminColors.cyanText : AdminColors.textSoft,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AdminColors.cyan.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "$count",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? AdminColors.textStrong : AdminColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dispatcher Action Drawer (Pin Clicked) ─────────────────────────────
  Widget _buildDispatcherDrawer(IncidentEntity inc) {
    final sector = BarangaySectorHelper.normalizeSector(inc.areaSector, inc.resolvedAddress);
    final urgency = _urgencyTone(inc.urgencyStatus);

    return AdminPanel(
      raised: true,
      accent: AdminColors.cyan,
      glow: true,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: SafeArea(
          child: Column(
            children: [
              // Drawer Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 14, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                ),
                child: Row(
                  children: [
                    const AdminIconTile(icon: Icons.radar_rounded, tone: AdminTone.cyan),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "TACTICAL DISPATCH DESK",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AdminColors.cyanSoft,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Case #${inc.id.substring(0, min(8, inc.id.length))}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      style: IconButton.styleFrom(
                        foregroundColor: AdminColors.textBody,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        fixedSize: const Size(36, 36),
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _drawerBadge(
                            inc.status.toUpperCase(),
                            inc.isSolved
                                ? AdminTone.green
                                : (inc.isInProgress
                                    ? AdminTone.blue
                                    : AdminTone.yellow),
                          ),
                          _drawerBadge(
                            (inc.urgencyStatus ?? "NORMAL").toUpperCase(),
                            urgency.$1,
                            solid: urgency.$2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Incident Category Title
                      Text(
                        inc.category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AdminColors.textStrong,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        inc.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AdminColors.textSoft,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Location & Address Block ─────────────────────────
                      AdminInset(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _drawerSectionHeader(Icons.location_on_outlined, "Location & Sector"),
                            const SizedBox(height: 10),
                            Text(
                              "Sector: $sector",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AdminColors.textStrong,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              inc.resolvedAddress ?? "Barangay Moonwalk",
                              style: const TextStyle(
                                fontSize: 13,
                                color: AdminColors.textSoft,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 1-Tap Google Maps External Directions Link
                            TextButton.icon(
                              onPressed: () {
                                final url = Uri.parse(
                                  "https://www.google.com/maps/search/?api=1&query=${inc.latitude},${inc.longitude}",
                                );
                                launchUrl(url, mode: LaunchMode.externalApplication);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AdminColors.primaryText,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.navigation_rounded, size: 15),
                              label: const Text(
                                "Navigate in Google Maps",
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Complainant & Emergency Contact Dossier ──────────
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(inc.reporterId).get(),
                        builder: (context, userSnap) {
                          final userData = userSnap.data?.data() as Map<String, dynamic>?;
                          final contactPerson = (userData?['emergencyContactName'] ?? userData?['emergencyContactPerson']) as String?;
                          final contactPhone = (userData?['emergencyContactNumber'] ?? userData?['emergencyContactPhone']) as String?;

                          return AdminInset(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _drawerSectionHeader(Icons.contact_phone_outlined, "Citizen & Emergency Dossier"),
                                const SizedBox(height: 10),
                                if (inc.isReportingOnBehalf) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: AdminPill(
                                      label: "REPORTED ON BEHALF: ${inc.victimName ?? 'Relative'}${inc.victimPhone != null && inc.victimPhone!.isNotEmpty ? ' • ${inc.victimPhone}' : ''}",
                                      tone: AdminTone.orange,
                                      icon: Icons.people_alt_rounded,
                                    ),
                                  ),
                                ],
                                if (inc.estimatedResponseTime != null &&
                                    inc.estimatedResponseTime!.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: AdminPill(
                                      label: "DISPATCH ETA: ${inc.estimatedResponseTime!}",
                                      tone: AdminTone.cyan,
                                      icon: Icons.timer_outlined,
                                    ),
                                  ),
                                ],
                                Text(
                                  inc.isAnonymous ? "Anonymous Citizen" : (inc.reporterName ?? "Resident"),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AdminColors.textStrong,
                                  ),
                                ),
                                if (!inc.isAnonymous && inc.reporterEmail != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    inc.reporterEmail!,
                                    style: const TextStyle(fontSize: 12, color: AdminColors.textLight),
                                  ),
                                ],
                                Divider(color: Colors.white.withValues(alpha: 0.08), height: 20),
                                Row(
                                  children: [
                                    const Icon(Icons.emergency_outlined, size: 15, color: AdminColors.dangerSoft),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "Emergency Contact: ",
                                      style: TextStyle(fontSize: 12, color: AdminColors.textLight, fontWeight: FontWeight.w600),
                                    ),
                                    Expanded(
                                      child: Text(
                                        contactPerson != null && contactPerson.isNotEmpty
                                            ? "$contactPerson ($contactPhone)"
                                            : "Not registered",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AdminColors.dangerText,
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AdminColors.slate,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
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
                                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.zoom_in, color: Colors.white, size: 14),
                                              SizedBox(width: 4),
                                              Text("Zoom", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
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
                        ),
                        const SizedBox(height: 18),
                      ],

                      // ── Video Evidence Preview ───────────────────────────
                      if (inc.videoUrl != null && inc.videoUrl!.isNotEmpty) ...[
                        _drawerSectionHeader(Icons.videocam_outlined, "Video Evidence"),
                        const SizedBox(height: 8),
                        AdminInset(
                          tone: AdminTone.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              const AdminIconTile(icon: Icons.videocam_rounded, size: 34),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  "Video Recording Attached",
                                  style: TextStyle(color: AdminColors.textStrong, fontSize: 12.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 150),
                                child: AdminButton(
                                  label: "Play In-App",
                                  icon: Icons.play_arrow_rounded,
                                  height: 36,
                                  onPressed: () {
                                    InAppEvidencePlayerDialog.show(
                                      context,
                                      videoUrl: inc.videoUrl!,
                                      title: "Incident #${inc.id.substring(0, min(8, inc.id.length))} Video Evidence",
                                    );
                                  },
                                ),
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
                        style: adminInputText,
                        cursorColor: AdminColors.cyan,
                        decoration: adminInputDecoration(
                          hint: "Enter Tanod patrol remarks, response logs...",
                        ),
                      ),
                      const SizedBox(height: 10),
                      AdminButton(
                        label: "Save Remarks",
                        icon: Icons.check,
                        style: AdminButtonStyle.ghost,
                        height: 40,
                        expand: true,
                        busy: _isSavingNotes,
                        onPressed: _isSavingNotes ? null : _saveNotesOnly,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Fixed Bottom Dispatch Action Buttons ─────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                ),
                child: Column(
                  children: [
                    if (inc.isPending) ...[
                      AdminButton(
                        label: "Dispatch Patrol (In Progress)",
                        icon: Icons.send_rounded,
                        height: 48,
                        expand: true,
                        onPressed: () => _showDispatchEtaDialog(context, inc),
                      ),
                    ] else if (inc.isInProgress) ...[
                      _SolveButton(
                        label: "Mark Incident Solved",
                        icon: Icons.check_circle_outline,
                        onPressed: () => _updateStatus("resolved"),
                      ),
                    ] else ...[
                      AdminButton(
                        label: "Re-Open Incident",
                        icon: Icons.replay_rounded,
                        style: AdminButtonStyle.slate,
                        height: 48,
                        expand: true,
                        onPressed: () => _showDispatchEtaDialog(context, inc),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Urgency badge: critical is solid red, high orange, medium yellow and
  // anything else slate.
  (AdminTone, bool) _urgencyTone(String? urgency) {
    return switch ((urgency ?? '').toLowerCase()) {
      'critical' => (AdminTone.red, true),
      'high' => (AdminTone.orange, false),
      'medium' => (AdminTone.yellow, false),
      _ => (AdminTone.slate, false),
    };
  }

  Widget _drawerBadge(String text, AdminTone tone, {bool solid = false}) {
    return AdminPill(label: text, tone: tone, solid: solid);
  }

  Widget _drawerSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AdminColors.cyanSoft),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: AdminColors.textHint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapControlButton(
    IconData icon,
    VoidCallback onTap,
    String tooltip, {
    AdminTone? tone,
  }) {
    // Dark glass under the icon action, so it reads over the map.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AdminColors.surfaceDeep.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(10),
        boxShadow: AdminColors.buttonShadow,
      ),
      child: AdminIconAction(
        icon: icon,
        tooltip: tooltip,
        onPressed: onTap,
        tone: tone,
        size: 42,
      ),
    );
  }
}

/// The rounded, edged card the live map sits in.
class _MapFrame extends StatelessWidget {
  const _MapFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(22);
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceDeep,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(borderRadius: radius, child: child),
    );
  }
}

/// A glass pill floating over the map: the live count, a filter or a
/// hotspot. A [gradient] fills it (a selected filter) and [glow] gives the
/// fill a coloured halo; otherwise it is dark glass with an [edge].
class _MapPill extends StatelessWidget {
  const _MapPill({
    required this.child,
    this.onTap,
    this.selected = false,
    this.gradient,
    this.edge,
    this.glow,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final Gradient? gradient;
  final Color? edge;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(999);
    final Gradient? fill = gradient;
    final Color? halo = glow;
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Center(widthFactor: 1, child: child),
    );

    final Widget pill = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 36,
      decoration: BoxDecoration(
        color: fill == null
            ? AdminColors.surfaceDeep.withValues(alpha: 0.86)
            : null,
        gradient: fill,
        borderRadius: radius,
        border: Border.all(
          color: fill == null
              ? (edge ?? Colors.white.withValues(alpha: 0.12))
              : Colors.white.withValues(alpha: 0.14),
        ),
        boxShadow: fill == null
            ? null
            : [
                if (halo != null)
                  BoxShadow(color: halo.withValues(alpha: 0.45), blurRadius: 16),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: onTap == null
          ? content
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: content,
              ),
            ),
    );

    if (onTap == null) return pill;
    return Semantics(button: true, selected: selected, child: pill);
  }
}

/// The green "solved" action at the foot of the dispatch desk, shaped like
/// a full-width [AdminButton]. The kit has no green style, so the success
/// colour is shaded down with black to carry white text.
class _SolveButton extends StatelessWidget {
  const _SolveButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(14);
    return Semantics(
      button: true,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.alphaBlend(
                Colors.black.withValues(alpha: 0.18),
                AdminColors.success,
              ),
              Color.alphaBlend(
                Colors.black.withValues(alpha: 0.32),
                AdminColors.success,
              ),
            ],
          ),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AdminColors.success.withValues(alpha: 0.3),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
