import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  GoogleMapController? _mapController;

  // Default coordinate (e.g., Moonwalk, Paranaque approx)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(14.4851, 121.0116),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    context.read<IncidentBloc>().add(const StreamActiveIncidentsRequested());
  }

  Widget appLogo() {
    return Container(
      height: 36,
      width: 36,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }

  Set<Marker> _buildMarkers(List<IncidentEntity> incidents) {
    return incidents.map((incident) {
      double hue;
      switch (incident.category.toLowerCase()) {
        case 'fire':
          hue = BitmapDescriptor.hueRed;
          break;
        case 'flood':
          hue = BitmapDescriptor.hueBlue;
          break;
        case 'medical':
          hue = BitmapDescriptor.hueGreen;
          break;
        default:
          hue = BitmapDescriptor.hueOrange;
      }

      return Marker(
        markerId: MarkerId(incident.id),
        position: LatLng(incident.latitude, incident.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        onTap: () => _showIncidentDetails(incident),
      );
    }).toSet();
  }

  void _showIncidentDetails(IncidentEntity incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(bottomSheetContext).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                incident.category,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                incident.description,
                style: const TextStyle(fontSize: 16, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.danger, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Urgency: ${incident.urgencyStatus}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.people, color: AppColors.darkGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Affected: ${incident.upvoteCount}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  String? userId;
                  if (authState is Authenticated) {
                    userId = authState.user.id;
                  }

                  final bool hasVoted = userId != null && incident.validatedUserIds.contains(userId);

                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasVoted ? Colors.grey : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: hasVoted || userId == null
                          ? null
                          : () {
                              // context.read<IncidentBloc>().add(
                              //   IncrementAffectedCountRequested(incident.id, userId!),
                              // );
                              Navigator.pop(bottomSheetContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Your report has been recorded."),
                                  backgroundColor: AppColors.darkGreen,
                                ),
                              );
                            },
                      icon: const Icon(Icons.front_hand),
                      label: Text(
                        hasVoted ? "Already Reported" : "Me Too / I am affected",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Row(
          children: [
            appLogo(),
            const SizedBox(width: 10),
            const Text(
              "Safety Map",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              child: Icon(Icons.person),
            ),
          ),
        ],
      ),
      body: BlocBuilder<IncidentBloc, IncidentState>(
        builder: (context, state) {
          List<IncidentEntity> activeIncidents = [];
          if (state is IncidentLoaded) {
            activeIncidents = state.incidents;
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialPosition,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (controller) => _mapController = controller,
                markers: _buildMarkers(activeIncidents),
              ),
              if (state is IncidentLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              // Floating Search Overlay Bar
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: AppColors.textLight, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Search locations or coordinates...",
                          style: TextStyle(color: AppColors.textLight, fontSize: 13),
                        ),
                      ),
                      Icon(Icons.filter_list, color: AppColors.darkGreen, size: 20),
                    ],
                  ),
                ),
              ),
              // Floating Controls Overlay (Zoom buttons)
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  children: [
                    _mapActionButton(Icons.add, () {
                      _mapController?.animateCamera(CameraUpdate.zoomIn());
                    }),
                    const SizedBox(height: 8),
                    _mapActionButton(Icons.remove, () {
                      _mapController?.animateCamera(CameraUpdate.zoomOut());
                    }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _mapActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textDark, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
