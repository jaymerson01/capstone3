class BarangaySectorHelper {
  const BarangaySectorHelper._();

  /// Known administrative sectors, subdivisions, and compounds in Barangay Moonwalk
  static const List<String> recognizedSectors = [
    'Area 1 - San Jose',
    'Area 2 - Airborne',
    'Area 3 - Multinational',
    'Area 4 - San Agustin',
    'Area 5 - Moonwalk Proper',
    'Simplicio Cruz Compound',
    'Multinational Village',
    'St. Francis Compound',
    'E. Rodriguez Ave',
    'Phimra Compound',
    'Armstrong Village',
    'Romance Compound',
    'Daang Batang',
    'Airport Village',
  ];

  /// Known coordinates and centroids for Barangay Moonwalk sectors for offline reverse-geocoding
  static const List<Map<String, dynamic>> sectorCentroids = [
    {
      'sector': 'Area 1 - San Jose',
      'lat': 14.4895,
      'lng': 121.0105,
      'address': 'San Jose (Area 1), Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'Area 2 - Airborne',
      'lat': 14.4835,
      'lng': 121.0090,
      'address': 'Airborne Compound (Area 2), Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'Area 3 - Multinational',
      'lat': 14.4940,
      'lng': 121.0185,
      'address': 'Multinational Village (Area 3), Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'Area 4 - San Agustin',
      'lat': 14.4815,
      'lng': 121.0135,
      'address': 'San Agustin (Area 4), Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'Area 5 - Moonwalk Proper',
      'lat': 14.4851,
      'lng': 121.0116,
      'address': 'Moonwalk Proper (Area 5), Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'Simplicio Cruz Compound',
      'lat': 14.4862,
      'lng': 121.0142,
      'address': 'Simplicio Cruz Compound, Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'Multinational Village',
      'lat': 14.4960,
      'lng': 121.0170,
      'address': 'Multinational Village, Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'St. Francis Compound',
      'lat': 14.4870,
      'lng': 121.0125,
      'address': 'St. Francis Compound, Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'E. Rodriguez Ave',
      'lat': 14.4860,
      'lng': 121.0100,
      'address': 'E. Rodriguez Ave, Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'Phimra Compound',
      'lat': 14.4845,
      'lng': 121.0080,
      'address': 'Phimra Compound, Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'Armstrong Village',
      'lat': 14.4880,
      'lng': 121.0150,
      'address': 'Armstrong Village, Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'Romance Compound',
      'lat': 14.4820,
      'lng': 121.0110,
      'address': 'Romance Compound, Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'Daang Batang',
      'lat': 14.4805,
      'lng': 121.0155,
      'address': 'Daang Batang, Barangay Moonwalk, Parañaque City',
    },
    {
      'sector': 'Airport Village',
      'lat': 14.4910,
      'lng': 121.0075,
      'address': 'Airport Village, Barangay Moonwalk, Parañaque City',
    },
  ];

  /// Finds the closest recognized Barangay Moonwalk sector/compound based on coordinates.
  static Map<String, dynamic> findClosestSector(double lat, double lng) {
    if (sectorCentroids.isEmpty) {
      return {
        'sector': 'Area 5 - Moonwalk Proper',
        'address': 'Moonwalk Proper, Barangay Moonwalk, Parañaque City',
      };
    }

    Map<String, dynamic> closest = sectorCentroids.first;
    double minDistanceSquared = double.infinity;

    for (final s in sectorCentroids) {
      final sLat = s['lat'] as double;
      final sLng = s['lng'] as double;
      final dLat = lat - sLat;
      final dLng = lng - sLng;
      final distSq = (dLat * dLat) + (dLng * dLng);

      if (distSq < minDistanceSquared) {
        minDistanceSquared = distSq;
        closest = s;
      }
    }

    return closest;
  }

  /// Checks whether a location string is just raw coordinates or "Pinned Location (...)"
  static bool isRawCoordinateOrGeneric(String? text) {
    if (text == null || text.trim().isEmpty) return true;
    final trimmed = text.trim();
    if (trimmed.startsWith('Pinned Location') ||
        trimmed.startsWith('GPS (') ||
        trimmed.startsWith('GPS Coordinates:')) {
      return true;
    }
    // Matches e.g. "14.485100, 121.011600" or "(14.4851, 121.0116)"
    final clean = trimmed.replaceAll(RegExp(r'[()\[\]]'), '').trim();
    final coordPattern = RegExp(r'^-?\d+\.\d+[\s,]+-?\d+\.\d+$');
    return coordPattern.hasMatch(clean);
  }

  /// Returns a clean, human-readable address from an incident or coordinate.
  static String formatReadableAddress({
    String? resolvedAddress,
    String? areaSector,
    double? latitude,
    double? longitude,
  }) {
    if (resolvedAddress != null &&
        resolvedAddress.trim().isNotEmpty &&
        !isRawCoordinateOrGeneric(resolvedAddress)) {
      return resolvedAddress.trim();
    }

    if (areaSector != null &&
        areaSector.trim().isNotEmpty &&
        !isRawCoordinateOrGeneric(areaSector)) {
      final normSector = normalizeSector(areaSector);
      return "$normSector, Barangay Moonwalk, Parañaque City";
    }

    if (latitude != null &&
        longitude != null &&
        (latitude != 0.0 || longitude != 0.0)) {
      final nearest = findClosestSector(latitude, longitude);
      return nearest['address'] as String;
    }

    return "Barangay Moonwalk, Parañaque City";
  }

  /// Normalizes any raw address or sector string into a clean, standardized
  /// Barangay sector / community name for accurate chart aggregation and reporting.
  static String normalizeSector(String? rawSector, [String? fallbackAddress]) {
    String input = (rawSector != null && rawSector.trim().isNotEmpty)
        ? rawSector.trim()
        : (fallbackAddress != null && fallbackAddress.trim().isNotEmpty
            ? fallbackAddress.trim()
            : '');

    if (input.isEmpty) {
      return 'Barangay Moonwalk';
    }

    // 1. Strip landmark notes in parentheses, e.g. "(Near Gate 1)" -> ""
    input = input.replaceAll(RegExp(r'\(.*?\)'), '').trim();

    // 2. Remove bullet separators, e.g. "Gate 1 • Moonwalk"
    if (input.contains('•')) {
      final parts = input.split('•');
      input = parts.first.trim();
    }

    final lower = input.toLowerCase();

    // 3. Match against known Barangay Moonwalk communities / compounds
    if (lower.contains('simplicio cruz')) {
      return 'Simplicio Cruz Compound';
    }
    if (lower.contains('multinational')) {
      return 'Multinational Village';
    }
    if (lower.contains('san jose') || lower.contains('area 1')) {
      return 'Area 1 - San Jose';
    }
    if (lower.contains('airborne') || lower.contains('area 2')) {
      return 'Area 2 - Airborne';
    }
    if (lower.contains('san agustin') || lower.contains('area 4')) {
      return 'Area 4 - San Agustin';
    }
    if (lower.contains('moonwalk proper') ||
        lower.contains('moonwalk core') ||
        lower.contains('area 5')) {
      return 'Area 5 - Moonwalk Proper';
    }
    if (lower.contains('st. francis') || lower.contains('st francis')) {
      return 'St. Francis Compound';
    }
    if (lower.contains('e. rodriguez') ||
        lower.contains('e rodriguez') ||
        lower.contains('e.rodriguez')) {
      return 'E. Rodriguez Ave';
    }
    if (lower.contains('phimra')) {
      return 'Phimra Compound';
    }
    if (lower.contains('armstrong')) {
      return 'Armstrong Village';
    }
    if (lower.contains('romance')) {
      return 'Romance Compound';
    }
    if (lower.contains('daang batang')) {
      return 'Daang Batang';
    }
    if (lower.contains('airport village')) {
      return 'Airport Village';
    }

    // 4. Strip boilerplate city and region names
    String cleaned = input;
    final removals = [
      ', parañaque city',
      ', paranaque city',
      ', parañaque',
      ', paranaque',
      'parañaque city',
      'paranaque city',
      'parañaque',
      'paranaque',
      ', metro manila',
      'metro manila',
      ', southern manila district',
      ', ncr',
      ', philippines',
      'philippines',
      'barangay moonwalk',
      'moonwalk',
    ];

    for (final r in removals) {
      cleaned = cleaned.replaceAll(RegExp(r, caseSensitive: false), '').trim();
    }

    // Strip trailing or leading commas/dashes/spaces
    cleaned = cleaned.replaceAll(RegExp(r'^[\s,\-]+|[\s,\-]+$'), '').trim();

    // If cleaned contains comma (e.g. "Subic Street, Villa San Antonio"), take the compound/neighborhood part
    if (cleaned.contains(',')) {
      final segments = cleaned
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      // Usually the last or second segment is the subdivision/compound name
      if (segments.length >= 2) {
        cleaned = segments.last;
      } else if (segments.isNotEmpty) {
        cleaned = segments.first;
      }
    }

    // Strip numeric street numbers at beginning (e.g. "1709 E Rodriguez" -> "E Rodriguez")
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+[\s\-/]+'), '').trim();

    if (cleaned.isEmpty || RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Barangay Moonwalk';
    }

    // Convert to Title Case
    return cleaned
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.length > 1 ? word.substring(1).toLowerCase() : ''}')
        .join(' ')
        .trim();
  }
}
