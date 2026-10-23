import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/features/incident/presentation/helpers/safety_kits_provider.dart';

List<String> kitFor(String category) =>
    SafetyKitsProvider.getInstructionsForCategory(category);

void main() {
  group('SafetyKitsProvider', () {
    test('Fire Incident reports get the fire kit', () {
      expect(kitFor('Fire Incident').first, contains('Evacuate immediately'));
    });

    test('Flood / Calamity reports get the flood kit', () {
      expect(kitFor('Flood / Calamity').first, contains('Monitor local water levels'));
    });

    test('Medical Emergency reports get the medical kit', () {
      expect(kitFor('Medical Emergency').first, contains('Check for responsiveness'));
    });

    test('older short category names still get the same kits', () {
      expect(kitFor('Fire'), kitFor('Fire Incident'));
      expect(kitFor('Flood/Typhoon'), kitFor('Flood / Calamity'));
    });

    test('categories without their own kit get the general kit', () {
      final general = kitFor('Other Emergency');
      expect(general.first, contains('Stay calm'));

      for (final category in [
        'Theft / Robbery',
        'Violence / Physical Fight',
        'Road Accident',
        'Suspicious Activity',
        'Lost Item / Missing Person',
        'Noise Complaint',
        'Other Emergency (Gas Leak)',
      ]) {
        expect(kitFor(category), general, reason: category);
      }
    });
  });
}
