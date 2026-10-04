class AppCoordinate {
  final double latitude;
  final double longitude;
  final String? address;
  final String? sector;

  const AppCoordinate({
    required this.latitude,
    required this.longitude,
    this.address,
    this.sector,
  });
}
