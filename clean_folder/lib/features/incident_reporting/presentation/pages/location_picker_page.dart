import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/core/presentation/widgets/map_search_bar.dart';
import 'package:community_safety_app/core/services/app_coordinate.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/services/location_service.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/map_styles.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/core/utils/moonwalk_area.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

/// Full-screen place picker for a report, like Google Maps or Grab: the pin
/// stays in the middle while you move the map (or search an address), the
/// address under it shows at the bottom, and "Use this location" returns it
/// as an [AppCoordinate].
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({
    super.key,
    required this.initial,
    this.initialAddress,
    this.focusSearch = false,
  });

  final LatLng initial;
  final String? initialAddress;

  /// Opens with the search box ready for typing.
  final bool focusSearch;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? _map;
  late LatLng _target = widget.initial;
  late String? _address = widget.initialAddress;
  String? _sector;
  bool _resolving = false;
  bool _skipNextLookup = false;
  int _lookup = 0;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onCameraIdle() {
    if (_skipNextLookup) {
      _skipNextLookup = false;
      return;
    }
    _debounce?.cancel();
    // Waits for the map to settle; also keeps address lookups under one a second.
    _debounce = Timer(const Duration(milliseconds: 700), _lookupAddress);
  }

  Future<void> _lookupAddress() async {
    final target = _target;
    final lookup = ++_lookup;
    setState(() => _resolving = true);
    AppCoordinate? found;
    try {
      found = await sl<LocationService>().reverseGeocode(target.latitude, target.longitude);
    } catch (e) {
      debugPrint('[LocationPicker] Address lookup failed: $e');
    }
    if (!mounted || lookup != _lookup) return;
    final nearest = BarangaySectorHelper.findClosestSector(target.latitude, target.longitude);
    setState(() {
      _resolving = false;
      _address = found?.address ?? nearest['address'] as String;
      _sector = found?.sector ?? nearest['sector'] as String;
    });
  }

  void _goTo(AppCoordinate place) {
    _lookup++; // drops a lookup still on its way
    _skipNextLookup = true;
    setState(() {
      _target = LatLng(place.latitude, place.longitude);
      _address = place.address;
      _sector = place.sector;
      _resolving = false;
    });
    _map?.animateCamera(CameraUpdate.newLatLngZoom(_target, 18));
  }

  Future<void> _goToMyLocation() async {
    try {
      final here = await sl<LocationService>().getCurrentLocation();
      if (here != null) _goTo(here);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inside = MoonwalkArea.contains(_target.latitude, _target.longitude);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: widget.initial, zoom: 17.5),
              cameraTargetBounds: MoonwalkArea.cameraBounds,
              minMaxZoomPreference: MoonwalkArea.zoomRange,
              style: MapStyles.current,
              // Keeps Google's logo above the address card.
              padding: const EdgeInsets.only(bottom: 190, top: 80),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              onMapCreated: (controller) => _map = controller,
              onCameraMove: (position) => _target = position.target,
              onCameraIdle: _onCameraIdle,
            ),
          ),

          // The pin, its tip on the centre of the map.
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 190 - 80),
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -22),
                  child: Icon(Icons.location_on_rounded, size: 48, color: AppColors.danger, shadows: const [
                    Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3)),
                  ]),
                ),
              ),
            ),
          ),

          // Back and search, along the top.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: AppColors.surface,
                      shape: const CircleBorder(),
                      elevation: 4,
                      child: IconButton(
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        icon: Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: MapSearchBar(onSelected: _goTo, autofocus: widget.focusSearch)),
                  ],
                ),
              ),
            ),
          ),

          // The address under the pin, and the buttons.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: AppColors.surface,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.mapMoveHint,
                          style: TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.place_rounded, color: AppColors.danger, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _resolving ? l10n.mapFindingAddress : (_address ?? l10n.mapFindingAddress),
                                key: const Key('picker-address'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!inside) ...[
                          const SizedBox(height: 6),
                          Text(l10n.reportOutsideMoonwalk, style: TextStyle(color: AppColors.danger, fontSize: 12.5)),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Material(
                              color: AppColors.surface,
                              shape: CircleBorder(side: BorderSide(color: AppColors.border)),
                              child: IconButton(
                                tooltip: l10n.mapMyLocation,
                                icon: Icon(Icons.my_location_rounded, color: AppColors.primary),
                                onPressed: _goToMyLocation,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Custom3dButton(
                                text: l10n.mapUseLocation,
                                icon: Icons.check_rounded,
                                onPressed: inside && !_resolving && _address != null
                                    ? () => Navigator.of(context).pop(AppCoordinate(
                                          latitude: _target.latitude,
                                          longitude: _target.longitude,
                                          address: _address,
                                          sector: _sector ??
                                              BarangaySectorHelper.findClosestSector(
                                                _target.latitude,
                                                _target.longitude,
                                              )['sector'] as String,
                                        ))
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
