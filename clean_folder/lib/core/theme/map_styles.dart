import 'package:community_safety_app/core/theme/app_colors.dart';

/// Google Maps styles in the RESQ Neo-Tactile palette: frost blocks, white
/// roads and soft green parks by day; deep navy at night. Pass
/// [MapStyles.current] to `GoogleMap.style`.
class MapStyles {
  const MapStyles._();

  /// The style for the current light or dark mode.
  static String get current => AppColors.isDarkMode ? dark : light;

  static const String light = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#E3EAF3"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#475569"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#F8FAFC"}]},
  {"featureType": "administrative", "elementType": "geometry.stroke", "stylers": [{"color": "#C3D0E2"}]},
  {"featureType": "landscape.man_made", "elementType": "geometry", "stylers": [{"color": "#D4DEEB"}]},
  {"featureType": "landscape.natural", "elementType": "geometry", "stylers": [{"color": "#E3EAF3"}]},
  {"featureType": "poi", "elementType": "geometry", "stylers": [{"color": "#DCE4EF"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#64748B"}]},
  {"featureType": "poi.business", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#CDE9DA"}]},
  {"featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [{"color": "#3F7D5E"}]},
  {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#FFFFFF"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#D3DDEA"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#64748B"}]},
  {"featureType": "road.highway", "elementType": "geometry.fill", "stylers": [{"color": "#F8FAFC"}]},
  {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#C3D0E2"}]},
  {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#D4DEEB"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#BFD8F4"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#2353D6"}]}
]
''';

  static const String dark = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#0E1A33"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#8392AB"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#0B1428"}]},
  {"featureType": "administrative", "elementType": "geometry.stroke", "stylers": [{"color": "#26334F"}]},
  {"featureType": "landscape.man_made", "elementType": "geometry", "stylers": [{"color": "#141E36"}]},
  {"featureType": "landscape.natural", "elementType": "geometry", "stylers": [{"color": "#0E1A33"}]},
  {"featureType": "poi", "elementType": "geometry", "stylers": [{"color": "#131F3A"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#6F88B0"}]},
  {"featureType": "poi.business", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#10302A"}]},
  {"featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [{"color": "#4E9C80"}]},
  {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#1C2742"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#141E36"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#A3B1C6"}]},
  {"featureType": "road.highway", "elementType": "geometry.fill", "stylers": [{"color": "#26334F"}]},
  {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#17263C"}]},
  {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#1A2540"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#081428"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#3D648F"}]}
]
''';
}
