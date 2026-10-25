import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_header_parts.dart';

Future<void> pumpPart(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.admin(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('AdminSirenButton says how many sirens are active', (
    tester,
  ) async {
    var taps = 0;
    await pumpPart(
      tester,
      AdminSirenButton(activeCount: 0, compact: false, onTap: () => taps++),
    );
    expect(find.text('BROADCAST SIREN'), findsOneWidget);
    await tester.tap(find.byType(AdminSirenButton));
    expect(taps, 1);

    await pumpPart(
      tester,
      AdminSirenButton(activeCount: 2, compact: false, onTap: () {}),
    );
    expect(find.text('2 ACTIVE SIREN • MANAGE'), findsOneWidget);
  });

  testWidgets('a compact AdminSirenButton keeps its label for screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await pumpPart(
      tester,
      AdminSirenButton(activeCount: 1, compact: true, onTap: () => taps++),
    );

    expect(find.text('1 ACTIVE SIREN • MANAGE'), findsNothing);
    expect(find.bySemanticsLabel('1 ACTIVE SIREN • MANAGE'), findsOneWidget);
    await tester.tap(find.byType(AdminSirenButton));
    expect(taps, 1);
    semantics.dispose();
  });

  testWidgets('AdminBellButton counts unread notifications', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await pumpPart(
      tester,
      AdminBellButton(unreadCount: 0, onTap: () => taps++),
    );
    expect(find.bySemanticsLabel('Dispatch notifications'), findsOneWidget);
    expect(find.byType(Text), findsNothing);
    await tester.tap(find.byType(AdminBellButton));
    expect(taps, 1);

    await pumpPart(tester, AdminBellButton(unreadCount: 3, onTap: () {}));
    expect(find.text('3'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Dispatch notifications, 3 new'),
      findsOneWidget,
    );

    await pumpPart(tester, AdminBellButton(unreadCount: 12, onTap: () {}));
    expect(find.text('9+'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('AdminHeaderButton shows its tooltip and reports taps', (
    tester,
  ) async {
    var taps = 0;
    await pumpPart(
      tester,
      AdminHeaderButton(
        icon: Icons.menu_open_rounded,
        tooltip: 'Toggle Sidebar',
        onPressed: () => taps++,
      ),
    );

    expect(find.byTooltip('Toggle Sidebar'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu_open_rounded));
    expect(taps, 1);
  });

  testWidgets('AdminUserChip shows the name and role except on phones', (
    tester,
  ) async {
    await pumpPart(
      tester,
      const AdminUserChip(displayName: 'Admin', initial: 'A', compact: false),
    );
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Municipal Dispatcher'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);

    await pumpPart(
      tester,
      const AdminUserChip(displayName: 'Admin', initial: 'A', compact: true),
    );
    expect(find.text('Admin'), findsNothing);
    expect(find.text('Municipal Dispatcher'), findsNothing);
    expect(find.text('A'), findsOneWidget);
  });
}
