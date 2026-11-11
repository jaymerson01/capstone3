import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/live_indicator.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/map_styles.dart';
import 'package:community_safety_app/core/utils/moonwalk_area.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/domain/repositories/incident_repository.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

/// For the reporter while a responder is on the way: the report and the
/// responder on one map, with how far away they are.
class ResponderLiveMap extends StatefulWidget {
  const ResponderLiveMap({super.key, required this.incident, this.repository});

  final IncidentEntity incident;
  final IncidentRepository? repository;

  @override
  State<ResponderLiveMap> createState() => _ResponderLiveMapState();
}

class _ResponderLiveMapState extends State<ResponderLiveMap> {
  late final Stream<({double lat, double lng, String? name, DateTime? at})?> _position =
      (widget.repository ?? sl<IncidentRepository>()).watchResponderPosition(widget.incident.id);
  GoogleMapController? _map;

  LatLng get _report => LatLng(widget.incident.latitude, widget.incident.longitude);

  void _frame(LatLng responder) {
    final south = _report.latitude < responder.latitude ? _report.latitude : responder.latitude;
    final north = _report.latitude < responder.latitude ? responder.latitude : _report.latitude;
    final west = _report.longitude < responder.longitude ? _report.longitude : responder.longitude;
    final east = _report.longitude < responder.longitude ? responder.longitude : _report.longitude;
    _map?.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east)),
      60,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<({double lat, double lng, String? name, DateTime? at})?>(
      stream: _position,
      builder: (context, snapshot) {
        final position = snapshot.data;
        final responder = position == null ? null : LatLng(position.lat, position.lng);
        if (responder != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _frame(responder));
        }
        final meters = responder == null
            ? null
            : Geolocator.distanceBetween(_report.latitude, _report.longitude, responder.latitude, responder.longitude);
        final at = position?.at;
        final time = at == null ? '—' : '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

        return GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const LiveIndicator(size: 9),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.liveMapTitle,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                meters == null ? l10n.liveMapWaiting : l10n.liveMapDistance((meters / 10).round() * 10, time),
                key: const Key('live-map-distance'),
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 240,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: _report, zoom: 16),
                    cameraTargetBounds: MoonwalkArea.cameraBounds,
                    minMaxZoomPreference: MoonwalkArea.zoomRange,
                    style: MapStyles.current,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    onMapCreated: (controller) {
                      _map = controller;
                      if (responder != null) _frame(responder);
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('report'),
                        position: _report,
                        infoWindow: InfoWindow(title: l10n.liveMapYourReport),
                      ),
                      if (responder != null)
                        Marker(
                          markerId: const MarkerId('responder'),
                          position: responder,
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                          infoWindow: InfoWindow(title: position?.name ?? widget.incident.assignedResponderName),
                        ),
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
