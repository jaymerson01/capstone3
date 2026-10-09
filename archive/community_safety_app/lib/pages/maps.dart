import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_color.dart';
import '../widgets/custom_3d_button.dart';
import '../widgets/custom_3d_card.dart';
import '../widgets/compact_map_legend.dart';
import '../utils/marker_generator.dart';
import '../admin/models/incident_report.dart';
import '../services/mock_database_service.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(14.4793, 121.0198); // Default Moonwalk / Manila center
  LatLng? _currentUserLocation;
  bool _isLoadingLocation = false;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _getUserCurrentLocation();
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

  Future<void> _getUserCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled on your device.'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        final userLatLng = LatLng(pos.latitude, pos.longitude);

        if (mounted) {
          setState(() {
            _currentUserLocation = userLatLng;
            _initialPosition = userLatLng;
          });

          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(userLatLng, 15.0),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission was denied.'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching location for map: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _recenterToCurrentLocation() async {
    if (_currentUserLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentUserLocation!, 16.0),
      );
    } else {
      await _getUserCurrentLocation();
    }
  }

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

  Future<Set<Marker>> _buildCustomMarkers(List<IncidentReport> reports, LatLng? userLoc) async {
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
            snippet: "Status: ${report.statusLabel}",
          ),
          onTap: () => _showIncidentDetailsModal(report),
        ),
      );
    }

    if (userLoc != null) {
      final userIcon = await MarkerGenerator.getUserLocationMarker();
      markers.add(
        Marker(
          markerId: const MarkerId('user_current_location'),
          position: userLoc,
          icon: userIcon,
          infoWindow: const InfoWindow(title: 'Your Current Location'),
        ),
      );
    }

    return markers;
  }

  void _showIncidentDetailsModal(IncidentReport report) {
    final statusColor = MarkerGenerator.getColorForStatus(report.status);
    final categoryIcon = MarkerGenerator.getCategoryIcon(report.incidentType);
    final urgencyColor = _getUrgencyColor(report.urgencyLevel);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1628),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: statusColor.withValues(alpha: 0.35)),
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
              // Drag handle
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

              // Header Row
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
                        const Text(
                          "Public Safety Alert • Community Verified",
                          style: TextStyle(
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
                      color: statusColor.withValues(alpha: 0.18),
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

              // Structured Info Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF060D1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2D4A)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.location_on,
                      "Incident Area",
                      report.location,
                    ),
                    if (report.latitude != null && report.longitude != null) ...[
                      const Divider(color: Color(0xFF1E2D4A), height: 16),
                      _buildInfoRow(
                        Icons.my_location,
                        "GPS Coordinates",
                        "${report.latitude!.toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}",
                      ),
                    ],
                    const Divider(color: Color(0xFF1E2D4A), height: 16),
                    Row(
                      children: [
                        const Icon(Icons.warning_rounded, size: 18, color: Color(0xFF0088FF)),
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
                    _buildInfoRow(
                      Icons.access_time,
                      "Reported Time",
                      "${report.date.day}/${report.date.month}/${report.date.year} ${report.date.hour}:${report.date.minute.toString().padLeft(2, '0')}",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Incident Description",
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

              const SizedBox(height: 24),

              Custom3dButton(
                icon: Icons.check,
                text: "Close Incident Details",
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0088FF)),
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
    final dbService = MockDatabaseService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: AppColors.primaryGlowShadow,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "User Safety Map",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: dbService,
        builder: (context, _) {
          // Filter ALL community incident reports with valid non-null coordinates
          final communityReports = dbService.reports.where((r) {
            final hasCoordinates = r.latitude != null && r.longitude != null;
            return !r.isArchived && hasCoordinates;
          }).toList();

          return FutureBuilder<Set<Marker>>(
            future: _buildCustomMarkers(communityReports, _currentUserLocation),
            builder: (context, snapshot) {
              final markers = snapshot.data ?? {};

              return Stack(
                children: [
                  // Interactive Google Map Container
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 14.0,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (_currentUserLocation != null) {
                        controller.animateCamera(
                          CameraUpdate.newLatLngZoom(_currentUserLocation!, 15.0),
                        );
                      }
                    },
                    markers: markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: true,
                  ),

                  // Header Overlay Card
                  Positioned(
                    top: 14,
                    left: 14,
                    right: 14,
                    child: Custom3dCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.my_location, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "User Safety Map",
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${communityReports.length} community incident(s) mapped",
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isLoadingLocation)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Compact Map Legend Overlay (Top Left below header)
                  const Positioned(
                    top: 76,
                    left: 14,
                    child: CompactMapLegend(showUserLocation: true),
                  ),

                  // Floating Controls Column (Recenter & Zoom)
                  Positioned(
                    bottom: 24,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Zoom in
                        FloatingActionButton.small(
                          heroTag: "zoom_in_btn",
                          backgroundColor: const Color(0xFF0A1628),
                          foregroundColor: const Color(0xFF0088FF),
                          onPressed: () {
                            _mapController?.animateCamera(CameraUpdate.zoomIn());
                          },
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(height: 8),
                        // Zoom out
                        FloatingActionButton.small(
                          heroTag: "zoom_out_btn",
                          backgroundColor: const Color(0xFF0A1628),
                          foregroundColor: const Color(0xFF0088FF),
                          onPressed: () {
                            _mapController?.animateCamera(CameraUpdate.zoomOut());
                          },
                          child: const Icon(Icons.remove),
                        ),
                        const SizedBox(height: 8),
                        // Recenter to Current Location Button
                        FloatingActionButton(
                          heroTag: "recenter_location_btn",
                          backgroundColor: const Color(0xFF0088FF),
                          foregroundColor: Colors.white,
                          onPressed: _recenterToCurrentLocation,
                          child: const Icon(Icons.my_location),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}