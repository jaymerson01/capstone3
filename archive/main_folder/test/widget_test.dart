import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:main_folder/core/services/shared_incident_database.dart';
import 'package:main_folder/features/incident_reporting/presentation/blocs/incident_bloc.dart';
import 'package:main_folder/features/incident_reporting/presentation/pages/incident_overview_page.dart';

void main() {
  testWidgets('IncidentOverviewPage renders properly and displays title', (WidgetTester tester) async {
    // Initialize the shared database first
    await SharedIncidentDatabase().init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<IncidentBloc>(
          create: (context) => IncidentBloc(),
          child: const IncidentOverviewPage(),
        ),
      ),
    );

    // Wait for the loading delay to complete and rebuild
    await tester.pumpAndSettle();

    // Verify that the title "Safe Moonwalk My Report" is visible in the AppBar.
    expect(find.text('Safe Moonwalk My Report'), findsOneWidget);

    // Verify that the header text "My Reports" is visible on the screen.
    expect(find.text('My Reports'), findsOneWidget);

    // Verify that the seeded mock incident 'House Fire on St. Francis Compound' is rendered.
    expect(find.textContaining('House Fire on St. Francis Compound'), findsOneWidget);
  });
}
