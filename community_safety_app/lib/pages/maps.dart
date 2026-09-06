import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_color.dart';
import '../widgets/custom_3d_button.dart';
import '../widgets/custom_3d_card.dart';
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

  double _getHueForStatus(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.pending:
        return BitmapDescriptor.hueOrange;
      case IncidentStatus.inProgress:
        return BitmapDescriptor.hueAzure;
      case IncidentStatus.solved:
        return BitmapDescriptor.hueGreen;
      case IncidentStatus.spam:
        return BitmapDescriptor.hueRed;
    }
  }

  Color _getColorForStatus(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.pending:
        return AppColors.pending;
      case IncidentStatus.inProgress:
        return AppColors.primary;
      case IncidentStatus.solved:
        return AppColors.solved;
      case IncidentStatus.spam:
        return AppColors.danger;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Fire Incident":
        return Icons.local_fire_department;
      case "Theft / Robbery":
        return Icons.local_police;
      case "Medical Emergency":
        return Icons.medical_services;
      case "Violence / Physical Fight":
        return Icons.warning_amber_rounded;
      case "Road Accident":
        return Icons.car_crash;
      case "Suspicious Activity":
        return Icons.visibility;
      case "Flood / Calamity":
        return Icons.flood;
      case "Lost Item / Missing Person":
        return Icons.person_search;
      case "Noise Complaint":
        return Icons.volume_up;
      default:
        return Icons.report_problem;
    }
  }

  void _showIncidentDetailsModal(IncidentReport report) {
    final statusColor = _getColorForStatus(report.status);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
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
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(report.incidentType),
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
                            color: AppColors.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Community Incident Alert",
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.35)),
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

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.location_on,
                      "Location",
                      report.location,
                    ),
                    if (report.latitude != null && report.longitude != null) ...[
                      const Divider(color: AppColors.border, height: 16),
                      _buildInfoRow(
                        Icons.my_location,
                        "Coordinates",
                        "${report.latitude!.toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}",
                      ),
                    ],
                    const Divider(color: AppColors.border, height: 16),
                    _buildInfoRow(
                      Icons.warning_rounded,
                      "Urgency Level",
                      report.urgencyLevel,
                    ),
                    const Divider(color: AppColors.border, height: 16),
                    _buildInfoRow(
                      Icons.access_time,
                      "Date & Time",
                      "${report.date.day}/${report.date.month}/${report.date.year} ${report.date.hour}:${report.date.minute.toString().padLeft(2, '0')}",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Description",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                report.description,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              Custom3dButton(
                icon: Icons.check,
                text: "Close Details",
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
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          "$title:",
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
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

          // Build Google Maps markers for all valid community incident reports
          final Set<Marker> markers = communityReports.map((report) {
            return Marker(
              markerId: MarkerId(report.id),
              position: LatLng(report.latitude!, report.longitude!),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _getHueForStatus(report.status),
              ),
              infoWindow: InfoWindow(
                title: report.incidentType,
                snippet: "Status: ${report.statusLabel}",
              ),
              onTap: () => _showIncidentDetailsModal(report),
            );
          }).toSet();

          // Add user's current location marker if available
          if (_currentUserLocation != null) {
            markers.add(
              Marker(
                markerId: const MarkerId('user_current_location'),
                position: _currentUserLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
                infoWindow: const InfoWindow(title: 'Your Current Location'),
              ),
            );
          }

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
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                      onPressed: () {
                        _mapController?.animateCamera(CameraUpdate.zoomIn());
                      },
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    // Zoom out
                    FloatingActionButton.small(
                      heroTag: "zoom_out_btn",
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                      onPressed: () {
                        _mapController?.animateCamera(CameraUpdate.zoomOut());
                      },
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 8),
                    // Recenter to Current Location Button
                    FloatingActionButton(
                      heroTag: "recenter_location_btn",
                      backgroundColor: AppColors.primary,
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
      ),
    );
  }
}