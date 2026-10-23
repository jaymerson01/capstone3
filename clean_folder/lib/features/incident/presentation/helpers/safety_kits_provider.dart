import 'package:community_safety_app/l10n/app_localizations.dart';

class SafetyKitsProvider {
  /// Returns a localized, step-by-step list of markdown strings for Safety Action Kits
  /// mapped specifically to Barangay Moonwalk's emergency protocols.
  static List<String> getInstructionsForCategory(
    AppLocalizations l10n,
    String category,
  ) {
    switch (category) {
      case 'Fire':
        return [
          l10n.kitFire1,
          l10n.kitFire2,
          l10n.kitFire3,
          l10n.kitFire4,
        ];
      case 'Flood/Typhoon':
        return [
          l10n.kitFlood1,
          l10n.kitFlood2,
          l10n.kitFlood3,
          l10n.kitFlood4,
        ];
      case 'Medical Emergency':
        return [
          l10n.kitMedical1,
          l10n.kitMedical2,
          l10n.kitMedical3,
          l10n.kitMedical4,
        ];
      case 'Earthquake':
        return [
          l10n.kitEarthquake1,
          l10n.kitEarthquake2,
          l10n.kitEarthquake3,
          l10n.kitEarthquake4,
        ];
      default:
        return [
          l10n.kitGeneral1,
          l10n.kitGeneral2,
          l10n.kitGeneral3,
        ];
    }
  }
}
