import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/services/location_service.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/pages/incident_detail_page.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';

class MapsPage extends StatefulWidget {
  final IncidentEntity? focusedIncident;
  final bool isRootTab;

  const MapsPage({super.key, this.focusedIncident, this.isRootTab = false});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  GoogleMapController? _mapController;
  String _selectedCategoryFilter = "All";

  // Default coordinate: Barangay Moonwalk, Paranaque City (or focused incident if provided)
  CameraPosition get _initialPosition {
    if (widget.focusedIncident != null &&
        widget.focusedIncident!.latitude != 0.0 &&
        widget.focusedIncident!.longitude != 0.0) {
      return CameraPosition(
        target: LatLng(
          widget.focusedIncident!.latitude,
          widget.focusedIncident!.longitude,
        ),
        zoom: 16.5,
      );
    }
    return const CameraPosition(
      target: LatLng(14.4851, 121.0116),
      zoom: 14.5,
    );
  }

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

  final List<String> _filterCategories = [
    "All",
    "Fire",
    "Medical",
    "Flood",
    "Theft",
    "Accident",
    "Violence",
  ];

  @override
  void initState() {
    super.initState();
    context.read<IncidentBloc>().add(const StreamActiveIncidentsRequested());
  }

  double _getMarkerHue(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('fire')) return BitmapDescriptor.hueRed;
    if (cat.contains('theft') || cat.contains('robbery')) {
      return BitmapDescriptor.hueOrange;
    }
    if (cat.contains('medical')) return BitmapDescriptor.hueAzure;
    if (cat.contains('flood') || cat.contains('calamity')) {
      return BitmapDescriptor.hueCyan;
    }
    if (cat.contains('accident') || cat.contains('road')) {
      return BitmapDescriptor.hueYellow;
    }
    if (cat.contains('violence') || cat.contains('fight')) {
      return BitmapDescriptor.hueViolet;
    }
    return BitmapDescriptor.hueRose;
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('fire')) return AppColors.danger;
    if (cat.contains('theft') || cat.contains('robbery')) {
      return AppColors.pending;
    }
    if (cat.contains('medical')) return const Color(0xFF0A84FF);
    if (cat.contains('flood') || cat.contains('calamity')) {
      return const Color(0xFF00D4FF);
    }
    if (cat.contains('accident') || cat.contains('road')) {
      return const Color(0xFFFFD166);
    }
    if (cat.contains('violence') || cat.contains('fight')) {
      return const Color(0xFF9D4EDD);
    }
    return AppColors.primary;
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('fire')) return Icons.local_fire_department_rounded;
    if (cat.contains('theft') || cat.contains('robbery')) {
      return Icons.local_police_rounded;
    }
    if (cat.contains('medical')) return Icons.medical_services_rounded;
    if (cat.contains('flood') || cat.contains('calamity')) {
      return Icons.flood_rounded;
    }
    if (cat.contains('accident') || cat.contains('road')) {
      return Icons.car_crash_rounded;
    }
    if (cat.contains('violence') || cat.contains('fight')) {
      return Icons.sports_kabaddi_rounded;
    }
    return Icons.warning_amber_rounded;
  }

  String _formatRelativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  Set<Marker> _buildMarkers(List<IncidentEntity> incidents) {
    final filtered = _selectedCategoryFilter == "All"
        ? incidents
        : incidents.where((inc) {
            return inc.category
                .toLowerCase()
                .contains(_selectedCategoryFilter.toLowerCase());
          }).toList();

    // Ensure focused incident is always visible even if another category filter is active
    if (widget.focusedIncident != null &&
        !filtered.any((inc) => inc.id == widget.focusedIncident!.id)) {
      filtered.add(widget.focusedIncident!);
    }

    return filtered.map((incident) {
      return Marker(
        markerId: MarkerId(incident.id),
        position: LatLng(incident.latitude, incident.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(incident.category)),
        infoWindow: InfoWindow(
          title: incident.category,
          snippet: "${incident.areaSector ?? 'Moonwalk'} • ${_formatRelativeTime(incident.timestamp)}",
          onTap: () => _showIncidentDetails(incident),
        ),
        onTap: () => _showIncidentDetails(incident),
      );
    }).toSet();
  }

  void _showIncidentDetails(IncidentEntity incident) {
    final authState = context.read<AuthBloc>().state;
    final String currentUserId =
        authState is Authenticated ? authState.user.id : "resident_demo_01";

    final bool isMyReport = incident.reporterId == currentUserId;
    final bool hasVoted = incident.validatedUserIds.contains(currentUserId);
    final int totalAffected = incident.upvoteCount + 1;
    final categoryColor = _getCategoryColor(incident.category);
    final categoryIcon = _getCategoryIcon(incident.category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(bottomSheetContext).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal drag handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 18),

              // Header: Category Icon + Title + Urgency
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: categoryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(categoryIcon, color: categoryColor, size: 24),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incident.category,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            // Area / Location Badge
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on_rounded,
                                        size: 11, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        incident.areaSector ?? "Moonwalk",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            // Relative time
                            Text(
                              _formatRelativeTime(incident.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Urgency Pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      incident.urgencyStatus ?? "PENDING",
                      style: TextStyle(color: AppColors.danger,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Description Snippet
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  incident.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textDark,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 16),

              // Corroboration & Total Affected Stats
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people_alt_rounded,
                        color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        totalAffected == 1
                            ? "1 citizen affected (original reporter). Awaiting neighborhood confirmation."
                            : "$totalAffected citizens affected (original reporter + ${incident.upvoteCount} neighbor${incident.upvoteCount == 1 ? '' : 's'})",
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Action Buttons Row
              Row(
                children: [
                  // "Me Too" Corroborate Button / "Your Report" State
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: isMyReport
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "You are the author of this report. Tap 'View Details' to track progress.",
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          : (hasVoted
                              ? null
                              : () {
                                  context.read<IncidentBloc>().add(
                                        UpvoteIncidentRequested(
                                          incident.id,
                                          currentUserId,
                                        ),
                                      );
                                  Navigator.pop(bottomSheetContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Your confirmation has been recorded! Dispatch alerted.",
                                      ),
                                      backgroundColor: AppColors.solved,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: isMyReport
                              ? null
                              : (hasVoted ? null : AppColors.primaryGradient),
                          color: isMyReport
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : (hasVoted
                                  ? AppColors.solved.withValues(alpha: 0.15)
                                  : null),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isMyReport
                                ? AppColors.primary.withValues(alpha: 0.4)
                                : (hasVoted
                                    ? AppColors.solved.withValues(alpha: 0.4)
                                    : Colors.transparent),
                          ),
                          boxShadow: (isMyReport || hasVoted)
                              ? null
                              : AppColors.primaryGlowShadow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isMyReport
                                  ? Icons.person_pin_circle_rounded
                                  : (hasVoted
                                      ? Icons.check_circle_rounded
                                      : Icons.front_hand_rounded),
                              color: isMyReport
                                  ? AppColors.primary
                                  : (hasVoted ? AppColors.solved : Colors.white),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              isMyReport
                                  ? "Your Report"
                                  : (hasVoted ? "Confirmed" : "I witnessed this"),
                              style: TextStyle(
                                color: isMyReport
                                    ? AppColors.primary
                                    : (hasVoted ? AppColors.solved : Colors.white),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),

                  // View Live Details Button
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IncidentDetailPage(
                              initialIncident: incident,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            "View Details",
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _animateToUserLocation() async {
    try {
      final loc = await sl<LocationService>().getCurrentLocation();
      if (loc != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(loc.latitude, loc.longitude),
            16.0,
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          height: 64 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: isDark ? 12 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (!widget.isRootTab) ...[
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                ],
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primary,
                        child: Icon(Icons.shield,
                            color: AppColors.textDark, size: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.cyanGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: const Text(
                    "COMMUNITY MAP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Spacer(),
                const _LiveBadge(),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Category Filter Bar ─────────────────────────────────────────
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.surface,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filterCategories.length,
              separatorBuilder: (ctx, idx) => SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _filterCategories[index];
                final isSelected = _selectedCategoryFilter == category;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategoryFilter = category);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textLight,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Main Map View ────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<IncidentBloc, IncidentState>(
              builder: (context, state) {
                List<IncidentEntity> activeIncidents = [];
                if (state is IncidentLoaded) {
                  activeIncidents = state.incidents
                      .where((inc) =>
                          inc.status.toLowerCase() != 'resolved' &&
                          inc.latitude != 0.0 &&
                          inc.longitude != 0.0)
                      .toList();
                }

                // If a focused incident is passed from dashboard, ensure it is available in the list
                if (widget.focusedIncident != null &&
                    widget.focusedIncident!.latitude != 0.0 &&
                    widget.focusedIncident!.longitude != 0.0) {
                  if (!activeIncidents.any((inc) => inc.id == widget.focusedIncident!.id)) {
                    activeIncidents.add(widget.focusedIncident!);
                  }
                }

                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: _initialPosition,
                      style: isDark ? _darkMapStyle : "[]",
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        if (widget.focusedIncident != null &&
                            widget.focusedIncident!.latitude != 0.0 &&
                            widget.focusedIncident!.longitude != 0.0) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  LatLng(
                                    widget.focusedIncident!.latitude,
                                    widget.focusedIncident!.longitude,
                                  ),
                                  16.5,
                                ),
                              );
                              _showIncidentDetails(widget.focusedIncident!);
                            }
                          });
                        }
                      },
                      markers: _buildMarkers(activeIncidents),
                    ),

                    if (state is IncidentLoading)
                      Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),

                    if (state is IncidentError)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: AppColors.warning.withValues(alpha: 0.95),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Icon(Icons.wifi_off_rounded, color: Colors.black87, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "You are currently offline. Live incidents cannot be loaded.",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Map Floating Zoom & Location Controls ──────────────
                    Positioned(
                      bottom: 52,
                      right: 16,
                      child: Column(
                        children: [
                          _MapControlButton(
                            icon: Icons.add,
                            onTap: () => _mapController?.animateCamera(
                              CameraUpdate.zoomIn(),
                            ),
                          ),
                          SizedBox(height: 8),
                          _MapControlButton(
                            icon: Icons.remove,
                            onTap: () => _mapController?.animateCamera(
                              CameraUpdate.zoomOut(),
                            ),
                          ),
                          SizedBox(height: 8),
                          _MapControlButton(
                            icon: Icons.my_location,
                            color: AppColors.primary,
                            onTap: _animateToUserLocation,
                          ),
                        ],
                      ),
                    ),

                    // ── Bottom Legend & Active Counter Bar ──────────────────
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.92),
                          border: Border(
                            top: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Row(
                          children: [
                            const _MapLegendDot(
                                color: AppColors.danger, label: "Fire"),
                            SizedBox(width: 12),
                            const _MapLegendDot(
                                color: AppColors.pending, label: "Theft"),
                            SizedBox(width: 12),
                            const _MapLegendDot(
                                color: Color(0xFF0A84FF), label: "Medical"),
                            SizedBox(width: 12),
                            const _MapLegendDot(
                                color: Color(0xFF00D4FF), label: "Flood"),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${activeIncidents.length} Active Incidents",
                                style: TextStyle(color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
      }
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  const _LiveBadge();
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.danger.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger
                          .withValues(alpha: 0.7 * _ctrl.value),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6),
              Text(
                "LIVE MAP",
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _MapControlButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  State<_MapControlButton> createState() => _MapControlButtonState();
}

class _MapControlButtonState extends State<_MapControlButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: widget.color != null
              ? widget.color!.withValues(alpha: _pressed ? 0.6 : 0.95)
              : AppColors.surface.withValues(alpha: _pressed ? 0.7 : 0.95),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: AppColors.textDark,
          size: 18,
        ),
      ),
    );
  }
}

class _MapLegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _MapLegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4),
            ],
          ),
        ),
        SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
