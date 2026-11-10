import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_sidebar.dart';

const _pages = [
  'Overview Dashboard',
  'Tactical Dispatch Map',
  'Incident Reports',
  'Reports & Analytics',
  'Citizen Directory',
  'Admin Audit Logs',
  'Profile Settings',
];

Future<void> pumpSidebar(
  WidgetTester tester, {
  required bool collapsed,
  int selected = 0,
  ValueChanged<int>? onSelected,
  VoidCallback? onLogout,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1440, 900);
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.admin(),
      home: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminSidebar(
              selectedIndex: selected,
              onItemSelected: onSelected ?? (_) {},
              isCollapsed: collapsed,
              onLogout: onLogout ?? () {},
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('AdminSidebar opens each page and logs out', (tester) async {
    int? picked;
    var loggedOut = 0;
    await pumpSidebar(
      tester,
      collapsed: false,
      onSelected: (i) => picked = i,
      onLogout: () => loggedOut++,
    );

    for (final page in _pages) {
      expect(find.text(page), findsOneWidget);
    }
    for (var i = 0; i < _pages.length; i++) {
      await tester.tap(find.text(_pages[i]));
      expect(picked, i, reason: _pages[i]);
    }

    await tester.tap(find.text('Logout Portal'));
    expect(loggedOut, 1);
  });

  testWidgets('AdminSidebar marks the open page as selected', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSidebar(tester, collapsed: false, selected: 2);

    expect(
      tester.getSemantics(find.text('Incident Reports')),
      isSemantics(isButton: true, isSelected: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.text('Citizen Directory')),
      isSemantics(isButton: true, isSelected: false, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('a collapsed AdminSidebar shows icons with tooltips', (
    tester,
  ) async {
    int? picked;
    await pumpSidebar(tester, collapsed: true, onSelected: (i) => picked = i);

    for (final page in _pages) {
      expect(find.text(page), findsNothing);
      expect(find.byTooltip(page), findsOneWidget);
    }
    expect(find.byTooltip('Logout Portal'), findsOneWidget);

    await tester.tap(find.byTooltip('Citizen Directory'));
    expect(picked, 4);
  });

  testWidgets('AdminSidebar never overflows while it opens or closes', (
    tester,
  ) async {
    for (final collapsed in [true, false, true]) {
      await pumpSidebar(tester, collapsed: collapsed);
      for (var frame = 0; frame < 12; frame++) {
        await tester.pump(const Duration(milliseconds: 20));
        expect(tester.takeException(), isNull, reason: 'collapsed: $collapsed');
      }
    }
  });
}
