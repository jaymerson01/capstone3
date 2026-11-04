import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'barangay_sector_helper.dart';

/// Barangay Moonwalk's extent on the maps: the box around the app's known
/// Moonwalk area points ([BarangaySectorHelper.sectorCentroids]), widened by
/// [margin] so the streets at the edges of each area still fit.
class MoonwalkArea {
  const MoonwalkArea._();

  /// About 450 m on each side.
  static const double margin = 0.004;

  static final LatLngBounds bounds = _boundsOfSectors();

  /// Keeps the maps centred on Moonwalk.
  static final CameraTargetBounds cameraBounds = CameraTargetBounds(bounds);

  /// Zoomed out no further than the whole barangay.
  static const MinMaxZoomPreference zoomRange = MinMaxZoomPreference(14, 20);

  static bool contains(double latitude, double longitude) =>
      latitude >= bounds.southwest.latitude &&
      latitude <= bounds.northeast.latitude &&
      longitude >= bounds.southwest.longitude &&
      longitude <= bounds.northeast.longitude;

  static LatLngBounds _boundsOfSectors() {
    final points = BarangaySectorHelper.sectorCentroids;
    final lats = points.map((p) => (p['lat'] as num).toDouble());
    final lngs = points.map((p) => (p['lng'] as num).toDouble());
    return LatLngBounds(
      southwest: LatLng(lats.reduce((a, b) => a < b ? a : b) - margin, lngs.reduce((a, b) => a < b ? a : b) - margin),
      northeast: LatLng(lats.reduce((a, b) => a > b ? a : b) + margin, lngs.reduce((a, b) => a > b ? a : b) + margin),
    );
  }
}
