import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:main_folder/utils/marker_generator.dart';
import 'package:main_folder/widgets/compact_map_legend.dart';
import 'package:main_folder/admin/models/incident_report.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MarkerGenerator Unit Tests', () {
    test('getColorForStatus returns correct colors for all statuses', () {
      expect(MarkerGenerator.getColorForStatus(IncidentStatus.pending), const Color(0xFFFF9800));
      expect(MarkerGenerator.getColorForStatus(IncidentStatus.inProgress), const Color(0xFF0088FF));
      expect(MarkerGenerator.getColorForStatus(IncidentStatus.solved), const Color(0xFF00E676));
      expect(MarkerGenerator.getColorForStatus(IncidentStatus.spam), const Color(0xFFFF334B));
    });

    test('getCategoryIcon returns appropriate IconData for category types', () {
      expect(MarkerGenerator.getCategoryIcon("Fire Incident"), Icons.local_fire_department);
      expect(MarkerGenerator.getCategoryIcon("Theft / Robbery"), Icons.local_police);
      expect(MarkerGenerator.getCategoryIcon("Medical Emergency"), Icons.medical_services);
      expect(MarkerGenerator.getCategoryIcon("Violence / Physical Fight"), Icons.warning_amber_rounded);
      expect(MarkerGenerator.getCategoryIcon("Road Accident"), Icons.car_crash);
      expect(MarkerGenerator.getCategoryIcon("Flood / Calamity"), Icons.flood);
      expect(MarkerGenerator.getCategoryIcon("Unknown Hazard"), Icons.report_problem);
    });
  });

  group('CompactMapLegend Widget Tests', () {
    testWidgets('Renders CompactMapLegend initial collapsed state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactMapLegend(showUserLocation: true),
          ),
        ),
      );

      expect(find.text("Map Legend"), findsOneWidget);
      expect(find.text("STATUS COLORS"), findsNothing);

      // Tap header to expand legend
      await tester.tap(find.text("Map Legend"));
      await tester.pumpAndSettle();

      expect(find.text("STATUS COLORS"), findsOneWidget);
      expect(find.text("INCIDENT ICONS"), findsOneWidget);
      expect(find.text("Your Current Location"), findsOneWidget);
      expect(find.text("Pending"), findsOneWidget);
      expect(find.text("In Progress"), findsOneWidget);
      expect(find.text("Solved"), findsOneWidget);
      expect(find.text("Spam"), findsOneWidget);
    });
  });
}
