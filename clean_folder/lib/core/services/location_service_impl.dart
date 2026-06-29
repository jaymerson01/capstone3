import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'app_coordinate.dart';
import 'location_service.dart';

class LocationServiceImpl implements LocationService {
  const LocationServiceImpl();

  bool _isWithinBarangayMoonwalk(double lat, double lng) {
    // Approximate bounding box bounds: Latitude 14.4850 to 14.5100; Longitude 121.0000 to 121.0250
    const double minLat = 14.4850;
    const double maxLat = 14.5100;
    const double minLng = 121.0000;
    const double maxLng = 121.0250;

    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }

  @override
  Future<AppCoordinate?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final lat = position.latitude;
      final lng = position.longitude;

      if (!_isWithinBarangayMoonwalk(lat, lng)) {
        throw const LocationOutOfBoundsException();
      }

      String derivedSubLocality = 'Unknown Zone';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // Extract the street name, thoroughfare, or subLocality
          final subLocalityData = place.subLocality ?? place.thoroughfare ?? place.street ?? '';
          if (subLocalityData.isNotEmpty) {
             derivedSubLocality = subLocalityData;
          }
        }
      } catch (_) {
        // Fallback gracefully if geocoding network request fails
      }

      final formattedAddress = '$derivedSubLocality, Barangay Moonwalk';

      return AppCoordinate(
        latitude: lat,
        longitude: lng,
        address: formattedAddress,
      );
    } on LocationOutOfBoundsException {
      rethrow;
    } catch (_) {
      return null;
    }
  }
}
