import 'app_coordinate.dart';

class LocationOutOfBoundsException implements Exception {
  final String message;
  const LocationOutOfBoundsException([this.message = 'Location is outside Barangay Moonwalk jurisdiction.']);
  
  @override
  String toString() => message;
}

abstract class LocationService {
  Future<AppCoordinate?> getCurrentLocation();
}
