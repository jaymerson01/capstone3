import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/widgets/home_sections.dart';

void main() {
  tearDown(() => AppColors.isDarkMode = false);

  Future<void> pumpSection(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.resident(),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('HomeHeroHeader', () {
    Widget header({int unread = 0, VoidCallback? onTap}) => HomeHeroHeader(
          welcomeLabel: 'Welcome back,',
          userName: 'Juan',
          placeLabel: 'Barangay Moonwalk • Resident',
          unreadCount: unread,
          onNotificationsTap: onTap ?? () {},
        );

    testWidgets('greets the resident and opens notifications', (tester) async {
      var opened = 0;
      await pumpSection(tester, header(unread: 3, onTap: () => opened++));

      expect(find.text('Welcome back,'), findsOneWidget);
      expect(find.text('Juan'), findsOneWidget);
      expect(find.text('Barangay Moonwalk • Resident'), findsOneWidget);
      expect(find.text('RESQ'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.notifications_active_rounded));
      expect(opened, 1);
    });

    testWidgets('caps the unread badge and hides it at zero', (tester) async {
      await pumpSection(tester, header(unread: 12));
      expect(find.text('9+'), findsOneWidget);

      await pumpSection(tester, header());
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });

  testWidgets('HomeSirenCard shows the live advisory', (tester) async {
    await pumpSection(
      tester,
      const HomeSirenCard(
        activeLabel: 'ACTIVE SIREN',
        alertType: 'Flood warning',
        title: 'EMERGENCY ADVISORY',
        message: 'Move to higher ground now.',
        targetLabel: 'Target: All Sectors',
      ),
    );

    expect(find.text('ACTIVE SIREN'), findsOneWidget);
    expect(find.text('FLOOD WARNING'), findsOneWidget);
    expect(find.text('EMERGENCY ADVISORY'), findsOneWidget);
    expect(find.text('Move to higher ground now.'), findsOneWidget);
    expect(find.text('Target: All Sectors'), findsOneWidget);
  });

  testWidgets('HomeMyReportsPanel opens My Reports from tiles and View All',
      (tester) async {
    var opened = 0;
    await pumpSection(
      tester,
      HomeMyReportsPanel(
        title: 'MY REPORTS STATUS',
        subtitle: 'Personal incident filings',
        viewAllLabel: 'View All',
        onOpenMyReports: () => opened++,
        stats: const [
          HomeStat(
            value: '1',
            label: 'Pending',
            sublabel: 'In Queue',
            color: AppColors.pending,
            icon: Icons.hourglass_empty_rounded,
          ),
          HomeStat(
            value: '2',
            label: 'Active',
            sublabel: 'Responding',
            color: AppColors.progress,
            icon: Icons.sync_rounded,
            highlight: true,
          ),
          HomeStat(
            value: '3',
            label: 'Solved',
            sublabel: 'Resolved',
            color: AppColors.solved,
            icon: Icons.check_circle_rounded,
          ),
        ],
      ),
    );

    for (final text in ['1', '2', '3', 'Pending', 'Active', 'Solved', 'In Queue']) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    await tester.tap(find.text('Active'));
    await tester.tap(find.text('View All'));
    expect(opened, 2);
  });

  group('Community incidents', () {
    Widget panel({VoidCallback? onTap}) => HomeCommunityPanel(
          title: 'Community Incidents',
          subtitle: 'Recent reports from nearby compounds and streets',
          activeLabel: '1 Active',
          children: [
            HomeIncidentRow(
              icon: Icons.flood,
              urgencyColor: AppColors.danger,
              title: 'Flood / Calamity',
              status: 'in_progress',
              statusLabel: 'In Progress',
              location: 'Purok 3, Barangay Moonwalk',
              time: 'Reported 10/25/2026',
              description: 'Knee-deep water near the chapel.',
              onTap: onTap ?? () {},
            ),
          ],
        );

    testWidgets('lists each incident and opens it on tap', (tester) async {
      var opened = 0;
      await pumpSection(tester, panel(onTap: () => opened++));

      for (final text in [
        'Community Incidents',
        '1 Active',
        'Flood / Calamity',
        'In Progress',
        'Purok 3, Barangay Moonwalk',
        'Reported 10/25/2026',
        'Knee-deep water near the chapel.',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      await tester.tap(find.text('Flood / Calamity'));
      expect(opened, 1);
    });

    testWidgets('lays out at night without errors', (tester) async {
      AppColors.isDarkMode = true;
      await pumpSection(tester, panel());
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('HomeVideoCard opens the guide when tapped', (tester) async {
    final semantics = tester.ensureSemantics();
    var opened = 0;
    await pumpSection(
      tester,
      HomeVideoCard(
        title: 'Video Instructions',
        subtitle: 'How to report safety issues in Moonwalk',
        onTap: () => opened++,
      ),
    );

    await tester.tap(find.text('Video Instructions'));
    expect(opened, 1);
    expect(
      tester.getSemantics(find.text('Video Instructions')),
      isSemantics(isButton: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('HomeVideoCard shows the video guide', (tester) async {
    await pumpSection(
      tester,
      const HomeVideoCard(
        title: 'Mga Video na Gabay',
        subtitle: 'Paano mag-ulat ng mga problema sa kaligtasan sa Moonwalk',
      ),
    );

    expect(find.text('Mga Video na Gabay'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the landscape hero paints in both modes', (tester) async {
    for (final dark in [false, true]) {
      AppColors.isDarkMode = dark;
      await pumpSection(
        tester,
        const SizedBox(height: 300, child: HomeHeroLandscape()),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
