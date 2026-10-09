abstract class GeoDecoder {
  /// Converts a pair of [latitude] and [longitude] GPS coordinates 
  /// into a human-readable descriptive address string.
  /// 
  /// Returns a [Future] with the address [String] or throws an exception on failure.
  Future<String> decodeLatitudeLongitude({
    required double latitude,
    required double longitude,
  });
}
