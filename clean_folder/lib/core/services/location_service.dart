import 'app_coordinate.dart';

abstract class LocationService {
  Future<AppCoordinate?> getCurrentLocation();
}
