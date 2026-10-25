import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/map_styles.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/neo_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_chip.dart';
import 'package:community_safety_app/core/presentation/neo/neo_icon_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_sheet.dart';
import 'package:community_safety_app/core/presentation/neo/neo_status_pill.dart';
import 'package:community_safety_app/core/presentation/neo/neo_surface.dart';
import 'package:community_safety_app/features/incident/presentation/widgets/incident_category_visuals.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/services/location_service.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/pages/incident_detail_page.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';
import 'package:community_safety_app/core/utils/localized_labels.dart';

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

  final List<String> _filterCategories = [
    "All",
    "Fire",
    "Medical",
    "Flood",
    "Theft",
    "Accident",
    "Violence",
  ];

  /// Chip text for a filter key. The keys stay English because they are
  /// matched against the stored category names.
  String _filterLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case "All":
        return l10n.mapsFilterAll;
      case "Fire":
        return l10n.mapsFilterFire;
      case "Medical":
        return l10n.mapsFilterMedical;
      case "Flood":
        return l10n.mapsFilterFlood;
      case "Theft":
        return l10n.mapsFilterTheft;
      case "Accident":
        return l10n.mapsFilterAccident;
      case "Violence":
        return l10n.mapsFilterViolence;
      default:
        return key;
    }
  }

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

  String _formatRelativeTime(DateTime timestamp) {
    final l10n = AppLocalizations.of(context);
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return l10n.timeShortJustNow;
    if (diff.inMinutes < 60) return l10n.timeShortMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeShortHours(diff.inHours);
    return l10n.timeShortDays(diff.inDays);
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
          title: LocalizedLabels.category(context, incident.category),
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
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        // "Me Too" corroborate button / "Your Report" state
        final Widget witnessAction;
        if (hasVoted && !isMyReport) {
          witnessAction = Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.solved.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.solved.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.solved, size: 18),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.mapsConfirmed,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.solved,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          witnessAction = NeoButton(
            label: isMyReport ? l10n.reportYourReport : l10n.mapsIWitnessed,
            icon: isMyReport
                ? Icons.person_pin_circle_rounded
                : Icons.front_hand_rounded,
            variant: isMyReport
                ? NeoButtonVariant.standard
                : NeoButtonVariant.primary,
            height: 48,
            expand: true,
            onPressed: isMyReport
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.mapsYouAreAuthor,
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                : () {
                    context.read<IncidentBloc>().add(
                          UpvoteIncidentRequested(
                            incident.id,
                            currentUserId,
                          ),
                        );
                    Navigator.pop(bottomSheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.mapsConfirmationRecorded,
                        ),
                        backgroundColor: AppColors.solved,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
          );
        }

        return NeoSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category Icon + Title + Urgency
              Row(
                children: [
                  IncidentCategoryTile(storedCategory: incident.category, size: 46),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocalizedLabels.category(context, incident.category),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "${incident.areaSector ?? "Moonwalk"} · ${_formatRelativeTime(incident.timestamp)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  // Urgency Pill
                  NeoStatusPill(
                    label: incident.urgencyStatus != null
                        ? LocalizedLabels.urgency(context, incident.urgencyStatus).toUpperCase()
                        : l10n.statusPending.toUpperCase(),
                    color: AppColors.danger,
                  ),
                ],
              ),
              SizedBox(height: 14),

              // Description Snippet
              Text(
                incident.description,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: AppColors.textDark.withValues(alpha: 0.85),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),

              // Corroboration & Total Affected Stats
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: NeoSurface.inset(radius: 16),
                child: Row(
                  children: [
                    Icon(Icons.people_alt_rounded,
                        color: AppColors.primaryText, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        totalAffected == 1
                            ? l10n.mapsAffectedOriginal
                            : l10n.mapsAffectedWithNeighbors(totalAffected, incident.upvoteCount),
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(flex: 3, child: witnessAction),
                  SizedBox(width: 10),

                  // View Live Details Button
                  Expanded(
                    flex: 2,
                    child: NeoButton(
                      label: l10n.mapsViewDetails,
                      variant: NeoButtonVariant.standard,
                      height: 48,
                      expand: true,
                      onPressed: () {
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
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          backgroundColor: AppColors.background,
          body: BlocBuilder<IncidentBloc, IncidentState>(
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
                  // ── Main Map View ──────────────────────────────────────────
                  Positioned.fill(
                    child: GoogleMap(
                      initialCameraPosition: _initialPosition,
                      style: MapStyles.current,
                      // Keeps Google's logo and attribution above the legend bar.
                      padding: const EdgeInsets.only(bottom: 76),
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
                  ),

                  if (state is IncidentLoading)
                    Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),

                  // ── Floating Header & Category Filter Bar ─────────────────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GlassCard(
                              blur: true,
                              padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                              child: Row(
                                children: [
                                  if (!widget.isRootTab) ...[
                                    NeoIconButton(
                                      icon: Icons.arrow_back_rounded,
                                      tooltip: l10n.commonBack,
                                      size: 42,
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.mapsTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColors.textDark,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          l10n.mapsActiveIncidents(activeIncidents.length),
                                          style: TextStyle(
                                            color: AppColors.textLight,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const _LiveBadge(),
                                ],
                              ),
                            ),
                            if (state is IncidentError) ...[
                              SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.wifi_off_rounded, color: Colors.black87, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        l10n.mapsOffline,
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
                            ],
                            SizedBox(height: 10),
                            SizedBox(
                              height: 48,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                padding: const EdgeInsets.only(bottom: 6),
                                itemCount: _filterCategories.length,
                                separatorBuilder: (ctx, idx) => SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final category = _filterCategories[index];
                                  return Center(
                                    child: NeoChip(
                                      label: _filterLabel(context, category),
                                      selected: _selectedCategoryFilter == category,
                                      onPressed: () {
                                        setState(() => _selectedCategoryFilter = category);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Map Floating Zoom & Location Controls ──────────────
                  Positioned(
                    bottom: 76,
                    right: 16,
                    child: Column(
                      children: [
                        _MapControlButton(
                          icon: Icons.add_rounded,
                          onTap: () => _mapController?.animateCamera(
                            CameraUpdate.zoomIn(),
                          ),
                        ),
                        SizedBox(height: 10),
                        _MapControlButton(
                          icon: Icons.remove_rounded,
                          onTap: () => _mapController?.animateCamera(
                            CameraUpdate.zoomOut(),
                          ),
                        ),
                        SizedBox(height: 10),
                        _MapControlButton(
                          icon: Icons.my_location_rounded,
                          primary: true,
                          onTap: _animateToUserLocation,
                        ),
                      ],
                    ),
                  ),

                  // ── Bottom Legend Bar ───────────────────────────────────
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: GlassCard(
                      blur: true,
                      borderRadius: 999,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _MapLegendDot(
                                color: AppColors.danger, label: l10n.mapsFilterFire),
                            SizedBox(width: 14),
                            _MapLegendDot(
                                color: AppColors.pending, label: l10n.mapsFilterTheft),
                            SizedBox(width: 14),
                            _MapLegendDot(
                                color: Color(0xFF0A84FF), label: l10n.mapsFilterMedical),
                            SizedBox(width: 14),
                            _MapLegendDot(
                                color: Color(0xFF00D4FF), label: l10n.mapsFilterFlood),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

/// "LIVE MAP" on an ink pill with a breathing cyan dot.
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(999),
            border: AppColors.isDarkMode
                ? Border.all(color: AppColors.secondary.withValues(alpha: 0.35))
                : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.35),
                blurRadius: 14,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary
                          .withValues(alpha: 0.4 + 0.5 * _ctrl.value),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).mapsLive,
                style: TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontSize: 11,
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

/// A round map control: raised white (night glass at night), or blue when
/// [primary].
class _MapControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  const _MapControlButton({
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  @override
  State<_MapControlButton> createState() => _MapControlButtonState();
}

class _MapControlButtonState extends State<_MapControlButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final fill = widget.primary ? NeoFill.primary : NeoFill.raised;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 46,
        height: 46,
        decoration: NeoSurface.decoration(
          fill,
          {if (_pressed) WidgetState.pressed},
          circle: true,
        ),
        child: Icon(
          widget.icon,
          color: NeoSurface.foreground(fill),
          size: 20,
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
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 5),
            ],
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
