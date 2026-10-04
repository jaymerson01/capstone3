import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'app_coordinate.dart';
import 'location_service.dart';

class LocationServiceImpl implements LocationService {
  const LocationServiceImpl();

  @override
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('[LocationService] Failed to open location settings: $e');
    }
  }

  @override
  Future<AppCoordinate?> getCurrentLocation() async {
    debugPrint('[LocationService] Starting real GPS acquisition...');

    // 1. Check if hardware Location/GPS is turned on in Android system settings
    bool serviceEnabled = false;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('[LocationService] isLocationServiceEnabled: $serviceEnabled');
    } catch (e) {
      debugPrint('[LocationService] Error checking isLocationServiceEnabled: $e');
    }

    if (!serviceEnabled) {
      debugPrint('[LocationService] Location service (GPS) is OFF.');
      throw Exception('GPS is turned off. Please swipe down from the top of your screen and turn on Location.');
    }

    // 2. Check and request app permissions
    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('[LocationService] Current permission: $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('[LocationService] Requested permission result: $permission');
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied. Please allow location access.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is permanently denied. Please enable it in your phone App Settings.');
    }

    // 3. Acquire REAL GPS Position
    Position? position;

    // Try fresh GPS position first with a 10-second timeout
    try {
      debugPrint('[LocationService] Requesting fresh GPS fix...');
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      debugPrint('[LocationService] Fresh GPS position acquired: ${position.latitude}, ${position.longitude}');
    } catch (freshErr) {
      debugPrint('[LocationService] Fresh GPS fix timed out/failed ($freshErr). Checking cached last-known position...');
      // Fallback to real cached position on the device
      try {
        position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          debugPrint('[LocationService] Using last-known device position: ${position.latitude}, ${position.longitude}');
        }
      } catch (lastErr) {
        debugPrint('[LocationService] getLastKnownPosition failed: $lastErr');
      }
    }

    // If still no position, try balanced accuracy as last resort for physical device
    if (position == null) {
      try {
        debugPrint('[LocationService] Attempting fused network/GPS provider...');
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
        debugPrint('[LocationService] Fused position acquired: ${position.latitude}, ${position.longitude}');
      } catch (fusedErr) {
        debugPrint('[LocationService] Fused provider failed: $fusedErr');
      }
    }

    if (position == null) {
      throw Exception('Could not acquire GPS fix. Please ensure you have GPS turned on and a clear signal.');
    }

    final lat = position.latitude;
    final lng = position.longitude;

    return await reverseGeocode(lat, lng);
  }

  @override
  Future<AppCoordinate?> reverseGeocode(double lat, double lng) async {
    // 1. High-precision OpenStreetMap / Nominatim first (specialized in PH micro-streets & compounds)
    final osmResult = await _reverseGeocodeNominatim(lat, lng);
    if (osmResult != null && osmResult.address != null && osmResult.address!.isNotEmpty) {
      return osmResult;
    }

    // 2. Fallback to device native placemark geocoder with comprehensive assembly
    final nearestSector = BarangaySectorHelper.findClosestSector(lat, lng);
    String derivedAddress = nearestSector['address'] as String;
    String derivedSector = nearestSector['sector'] as String;

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 5));
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final List<String> addressParts = [];

        final thoroughfare = place.thoroughfare?.trim() ?? '';
        final street = place.street?.trim() ?? '';
        final subLocality = place.subLocality?.trim() ?? '';
        final locality = place.locality?.trim() ?? '';

        // Check if thoroughfare (street name like "Subic Street") is distinct from street/compound
        if (thoroughfare.isNotEmpty) {
          addressParts.add(thoroughfare);
        }

        // Add street/compound if non-empty and not identical to thoroughfare
        if (street.isNotEmpty &&
            !addressParts.contains(street) &&
            !street.toLowerCase().contains(thoroughfare.toLowerCase())) {
          addressParts.add(street);
        }

        // Sublocality / Compound / Barangay
        if (subLocality.isNotEmpty && !addressParts.contains(subLocality)) {
          addressParts.add(subLocality);
        }

        // Locality / City
        final formattedLocality = (locality.toLowerCase().contains('parañaque') ||
                locality.toLowerCase().contains('paranaque'))
            ? 'Parañaque City'
            : locality;

        if (formattedLocality.isNotEmpty && !addressParts.contains(formattedLocality)) {
          addressParts.add(formattedLocality);
        }

        if (addressParts.isNotEmpty) {
          derivedAddress = addressParts.join(', ');
        }

        derivedSector = BarangaySectorHelper.normalizeSector(
          subLocality.isNotEmpty ? subLocality : street,
          derivedAddress,
        );
      }
    } catch (geoErr) {
      debugPrint('[LocationService] Reverse geocoding fallback: $geoErr. Using sector: $derivedSector');
    }

    return AppCoordinate(
      latitude: lat,
      longitude: lng,
      address: derivedAddress,
      sector: derivedSector,
    );
  }

  /// High-precision reverse geocoding via OpenStreetMap Nominatim
  Future<AppCoordinate?> _reverseGeocodeNominatim(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1',
      );
      final response = await http
          .get(uri, headers: {
            'User-Agent': 'ResQCommunitySafetyApp/1.0 (contact: support@resq.ph)',
            'Accept-Language': 'en-US,en;q=0.9',
          })
          .timeout(const Duration(milliseconds: 3500));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>?;
        if (data != null && data['address'] != null) {
          final addr = data['address'] as Map<String, dynamic>;
          final road = addr['road'] as String?;
          final neighbourhood = (addr['neighbourhood'] ??
              addr['subdivision'] ??
              addr['hamlet'] ??
              addr['residential'] ??
              addr['commercial']) as String?;
          final quarter = (addr['quarter'] ??
              addr['suburb'] ??
              addr['village']) as String?;
          final rawCity = (addr['city'] ??
                  addr['town'] ??
                  addr['municipality'] ??
                  'Parañaque City')
              .toString();

          final List<String> parts = [];
          if (road != null && road.trim().isNotEmpty) {
            parts.add(road.trim());
          }
          if (neighbourhood != null &&
              neighbourhood.trim().isNotEmpty &&
              !parts.contains(neighbourhood.trim())) {
            parts.add(neighbourhood.trim());
          }
          if (parts.isEmpty && quarter != null && quarter.trim().isNotEmpty) {
            parts.add(quarter.trim());
          }

          final formattedCity = (rawCity.toLowerCase().contains('parañaque') ||
                  rawCity.toLowerCase().contains('paranaque'))
              ? 'Parañaque City'
              : rawCity;

          if (formattedCity.isNotEmpty && !parts.contains(formattedCity)) {
            parts.add(formattedCity);
          }

          final addressStr = parts.join(', ');
          final rawSectorCandidate = neighbourhood ?? quarter ?? road;
          final sectorStr = BarangaySectorHelper.normalizeSector(
            rawSectorCandidate,
            addressStr,
          );

          if (parts.isNotEmpty) {
            debugPrint('[LocationService] Nominatim geocode success: $addressStr (Sector: $sectorStr)');
            return AppCoordinate(
              latitude: lat,
              longitude: lng,
              address: addressStr,
              sector: sectorStr,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('[LocationService] Nominatim reverse geocode skipped: $e');
    }
    return null;
  }
}
