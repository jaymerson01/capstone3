import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/presentation/neo/live_indicator.dart';
import 'package:community_safety_app/core/presentation/neo/neo_tag.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/widgets/my_report_card.dart';

void main() {
  tearDown(() => AppColors.isDarkMode = false);

  Future<void> pumpCard(WidgetTester tester, Widget card,
      {double width = 390}) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.resident(),
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [card],
          ),
        ),
      ),
    );
  }

  MyReportCard card({
    bool synced = true,
    String? onBehalf,
    String? eta,
    VoidCallback? onTap,
    String category = 'Fire Incident',
    String location = 'E. Rodriguez Ave, Barangay Moonwalk, Parañaque City',
    String statusLabel = 'In Progress',
    String viewDetails = 'View Details',
  }) =>
      MyReportCard(
        storedCategory: 'Fire Incident',
        categoryLabel: category,
        location: location,
        time: '24/10/2026 09:30',
        statusLabel: statusLabel,
        statusColor: AppColors.progress,
        isSynced: synced,
        syncLabel: synced ? 'Live' : 'Local',
        onBehalfLabel: onBehalf,
        etaLabel: eta,
        viewDetailsLabel: viewDetails,
        highlight: true,
        onTap: onTap ?? () {},
      );

  testWidgets('shows the report and opens it from anywhere on the card',
      (tester) async {
    final semantics = tester.ensureSemantics();
    var opened = 0;
    await pumpCard(tester, card(onTap: () => opened++));

    for (final text in [
      'Fire Incident',
      'E. Rodriguez Ave, Barangay Moonwalk, Parañaque City',
      '24/10/2026 09:30',
      'In Progress',
      'Live',
      'View Details',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.byType(LiveIndicator), findsOneWidget);

    await tester.tap(find.text('View Details'));
    await tester.tap(find.text('Fire Incident'));
    expect(opened, 2);
    expect(
      tester.getSemantics(find.text('Fire Incident')),
      isSemantics(isButton: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('a report still on the phone says Local, without the live dot',
      (tester) async {
    await pumpCard(tester, card(synced: false));

    expect(find.text('Local'), findsOneWidget);
    expect(find.byType(LiveIndicator), findsNothing);
    expect(find.byIcon(Icons.smartphone_rounded), findsOneWidget);
  });

  testWidgets('tags appear only when given', (tester) async {
    await pumpCard(tester, card());
    expect(find.byType(NeoTag), findsNothing);

    await pumpCard(tester, card(onBehalf: 'For: Maria', eta: 'ETA: 5 min'));
    expect(find.text('For: Maria'), findsOneWidget);
    expect(find.text('ETA: 5 min'), findsOneWidget);
  });

  testWidgets('long Filipino text fits a small phone, day and night',
      (tester) async {
    for (final dark in [false, true]) {
      AppColors.isDarkMode = dark;
      await pumpCard(
        tester,
        card(
          category: 'Nawawalang Gamit / Nawawalang Tao',
          statusLabel: 'Inaaksyunan',
          viewDetails: 'Tingnan ang Detalye',
          onBehalf: 'Para kay: Maria Clara de los Santos',
          eta: 'ETA: 10 minuto',
        ),
        width: 360,
      );
      expect(tester.takeException(), isNull, reason: 'dark: $dark');
    }
  });
}
