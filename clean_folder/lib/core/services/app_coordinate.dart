class AppCoordinate {
  final double latitude;
  final double longitude;
  final String? address;

  const AppCoordinate({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}
