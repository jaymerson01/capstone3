import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/features/incident/presentation/widgets/incident_category_visuals.dart';

void main() {
  tearDown(() => AppColors.isDarkMode = false);

  test('each stored category has its own icon', () {
    const stored = [
      'Fire Incident',
      'Theft / Robbery',
      'Medical Emergency',
      'Violence / Physical Fight',
      'Road Accident',
      'Suspicious Activity',
      'Flood / Calamity',
      'Lost Item / Missing Person',
      'Noise Complaint',
      'Other Emergency',
    ];
    final icons = stored.map((c) => IncidentCategoryVisual.of(c).icon).toSet();
    expect(icons, hasLength(stored.length));
    expect(IncidentCategoryVisual.of('Fire Incident').icon,
        Icons.local_fire_department_rounded);
  });

  test('typed "Other" categories and unknown values look like Other', () {
    final other = IncidentCategoryVisual.of('Other Emergency');
    expect(IncidentCategoryVisual.of('Other Emergency (Gas Leak)').icon,
        other.icon);
    expect(IncidentCategoryVisual.of('Something new').icon, other.icon);
  });

  test('icons are lighter at night', () {
    final fire = IncidentCategoryVisual.of('Fire Incident');
    final day = fire.foreground;
    AppColors.isDarkMode = true;
    expect(fire.foreground, isNot(day));
    expect(fire.foreground.computeLuminance(), greaterThan(day.computeLuminance()));
  });

  testWidgets('IncidentCategoryTile paints in both modes', (tester) async {
    for (final dark in [false, true]) {
      AppColors.isDarkMode = dark;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.resident(),
          home: const Scaffold(
            body: Center(
              child: IncidentCategoryTile(storedCategory: 'Flood / Calamity'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.flood_rounded), findsOneWidget);
      expect(tester.getSize(find.byType(IncidentCategoryTile)),
          const Size(46, 46));
      expect(tester.takeException(), isNull);
    }
  });
}
