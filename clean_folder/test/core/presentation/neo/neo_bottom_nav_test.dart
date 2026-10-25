import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/presentation/neo/neo_bottom_nav.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';

const items = [
  NeoNavItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Home',
  ),
  NeoNavItem(
    icon: Icons.assignment_outlined,
    selectedIcon: Icons.assignment_rounded,
    label: 'Reports',
  ),
  NeoNavItem(
    icon: Icons.map_outlined,
    selectedIcon: Icons.map_rounded,
    label: 'Map',
  ),
  NeoNavItem(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'More',
  ),
];

void main() {
  tearDown(() => AppColors.isDarkMode = false);

  Future<void> pumpNav(
    WidgetTester tester, {
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    VoidCallback? onReport,
  }) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.resident(),
        home: Scaffold(
          extendBody: true,
          body: const SizedBox.expand(),
          bottomNavigationBar: NeoBottomNav(
            items: items,
            currentIndex: currentIndex,
            onTap: onTap ?? (_) {},
            reportLabel: 'REPORT',
            onReport: onReport ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('reports tab taps by index', (tester) async {
    final tapped = <int>[];
    await pumpNav(tester, onTap: tapped.add);

    await tester.tap(find.text('Map'));
    await tester.tap(find.text('Reports'));
    await tester.tap(find.text('More'));
    expect(tapped, [2, 1, 3]);
  });

  testWidgets('marks the current tab and shows its filled icon',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpNav(tester, currentIndex: 1);

    expect(find.byIcon(Icons.assignment_rounded), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Reports')),
      isSemantics(label: 'Reports', isButton: true, isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('Home')),
      isSemantics(label: 'Home', isButton: true, isSelected: false),
    );
    semantics.dispose();
  });

  testWidgets('the REPORT button sits in the middle and calls onReport',
      (tester) async {
    final semantics = tester.ensureSemantics();
    var reports = 0;
    await pumpNav(tester, onReport: () => reports++);

    await tester.tap(find.text('REPORT'));
    expect(reports, 1);
    expect(
      tester.getSemantics(find.text('REPORT')),
      isSemantics(label: 'REPORT', isButton: true, hasTapAction: true),
    );
    expect(tester.getCenter(find.text('REPORT')).dx, closeTo(195, 1));
    semantics.dispose();
  });

  testWidgets('keeps clear of the home indicator', (tester) async {
    tester.view.padding = const FakeViewPadding(bottom: 34);
    await pumpNav(tester);

    final bar = tester.getRect(find.byType(NeoBottomNav));
    expect(bar.bottom, 844);
    expect(tester.getBottomLeft(find.text('Home')).dy, lessThan(844 - 34));
  });

  testWidgets('renders in dark mode', (tester) async {
    AppColors.isDarkMode = true;
    await pumpNav(tester, currentIndex: 2);

    expect(find.text('Map'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
