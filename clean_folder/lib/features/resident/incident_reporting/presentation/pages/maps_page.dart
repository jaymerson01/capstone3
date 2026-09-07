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
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';

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
      width: 32,
      height: 32,
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
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.primary,
            child: const Icon(Icons.shield, color: Colors.white, size: 14),
          ),
        ),
      ),
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
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
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
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
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
                  const Icon(Icons.people, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Affected: ${incident.upvoteCount}",
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
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
                                  backgroundColor: AppColors.primary,
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
        height: 64 + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
              bottom: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                onPressed: () => Navigator.pop(context),
              ),
              appLogo(),
              const SizedBox(width: 10),
              const Text(
                "Safety Map",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppColors.primary, size: 20),
              ),
            ],
          ),
        ),
      ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Header ─────────────────────────────────────────────
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Safety Map",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Text(
                      "Active Moonwalk Perimeters",
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textLight),
                    ),
                  ],
                ),
                const Spacer(),
                const _LiveBadge(),
              ],
            ),
            const SizedBox(height: 14),

            // ── Map Frame ──────────────────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BlocBuilder<IncidentBloc, IncidentState>(
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
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            onMapCreated: (controller) => _mapController = controller,
                            markers: _buildMarkers(activeIncidents),
                          ),
                          
                          if (state is IncidentLoading)
                            const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          
                          // ── Floating Glass Search Bar ──────────────────────────
                          Positioned(
                            top: 14,
                            left: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search,
                                      color: AppColors.textLight, size: 18),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      "Search locations or coordinates...",
                                      style: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.filter_list,
                                        color: AppColors.primary, size: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Premium Zoom Controls ─────────────────────────────
                          Positioned(
                            bottom: 60, // Above the legend strip
                            right: 16,
                            child: Column(
                              children: [
                                _MapControlButton(
                                    icon: Icons.add, onTap: () {
                                      _mapController?.animateCamera(CameraUpdate.zoomIn());
                                    }),
                                const SizedBox(height: 8),
                                _MapControlButton(
                                    icon: Icons.remove, onTap: () {
                                      _mapController?.animateCamera(CameraUpdate.zoomOut());
                                    }),
                                const SizedBox(height: 8),
                                _MapControlButton(
                                  icon: Icons.my_location,
                                  onTap: () {
                                    // Normally fetch location here and animate
                                  },
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),

                          // ── Bottom status strip ───────────────────────────────
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.85),
                              ),
                              child: Row(
                                children: [
                                  const _MapLegendDot(
                                      color: AppColors.danger, label: "Fire"),
                                  const SizedBox(width: 16),
                                  const _MapLegendDot(
                                      color: AppColors.pending, label: "Theft"),
                                  const SizedBox(width: 16),
                                  const _MapLegendDot(
                                      color: AppColors.solved, label: "Medical"),
                                  const Spacer(),
                                  Text(
                                    "${activeIncidents.length} Active",
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
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
              ),
            ),
            const SizedBox(height: 14),

            // ── CTA Button ─────────────────────────────────────────────────
            Custom3dButton(
              icon: Icons.map,
              text: "Open in Google Maps",
              gradient: AppColors.primaryGradient,
              onPressed: () {},
            ),
          ],
        ),
      ),
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
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger
                          .withValues(alpha: 0.7 * _ctrl.value),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                "LIVE",
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
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
  const _MapControlButton({required this.icon, required this.onTap, this.color});

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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: widget.color != null
              ? widget.color!.withValues(alpha: _pressed ? 0.4 : 0.9)
              : Colors.white.withValues(alpha: _pressed ? 0.7 : 1.0),
          shape: BoxShape.circle,
          border: Border.all(
            color: (widget.color ?? Colors.grey)
                .withValues(alpha: _pressed ? 0.5 : 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: widget.color != null ? Colors.white : AppColors.textDark,
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: AppColors.textDark, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
