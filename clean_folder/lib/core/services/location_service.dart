import 'app_coordinate.dart';

class LocationOutOfBoundsException implements Exception {
  final String message;
  const LocationOutOfBoundsException([this.message = 'Location is outside Barangay Moonwalk jurisdiction.']);
  
  @override
  String toString() => message;
}

/// Thrown by [LocationService] with a [code] so screens can show a translated
/// message. [toString] keeps the original English text so existing handling
/// (which strips "Exception: ") behaves exactly as before.
class LocationServiceException implements Exception {
  final String code;
  final String message;
  const LocationServiceException(this.code, this.message);

  @override
  String toString() => 'Exception: $message';
}

abstract class LocationService {
  Future<AppCoordinate?> getCurrentLocation();
  Future<AppCoordinate?> reverseGeocode(double latitude, double longitude);
  Future<void> openLocationSettings();
}
