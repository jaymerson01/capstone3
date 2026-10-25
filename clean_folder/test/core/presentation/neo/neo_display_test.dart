import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/presentation/neo/live_indicator.dart';
import 'package:community_safety_app/core/presentation/neo/neo_list_row.dart';
import 'package:community_safety_app/core/presentation/neo/neo_section_header.dart';
import 'package:community_safety_app/core/presentation/neo/neo_status_pill.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';

Future<void> pumpNeo(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.resident(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  tearDown(() => AppColors.isDarkMode = false);

  group('NeoStatusPill', () {
    testWidgets('takes its hue from AppColors.statusColor', (tester) async {
      await pumpNeo(
        tester,
        NeoStatusPill.status(status: 'pending', label: 'Nakabinbin'),
      );

      expect(find.text('Nakabinbin'), findsOneWidget);
      expect(
        tester.widget<NeoStatusPill>(find.byType(NeoStatusPill)).color,
        AppColors.pending,
      );
    });

    for (final dark in [false, true]) {
      testWidgets('keeps its text readable (${dark ? 'dark' : 'light'} mode)',
          (tester) async {
        AppColors.isDarkMode = dark;
        for (final status in ['pending', 'in_progress', 'resolved', 'cancelled']) {
          await pumpNeo(tester, NeoStatusPill.status(status: status, label: status));

          final tint = (tester
                  .widget<Container>(find.descendant(
                    of: find.byType(NeoStatusPill),
                    matching: find.byType(Container),
                  ))
                  .decoration as BoxDecoration)
              .color!;
          final text = tester.widget<Text>(find.text(status)).style!.color!;
          final ground = Color.alphaBlend(tint, AppColors.surface);
          expect(contrast(text, ground), greaterThanOrEqualTo(4.5), reason: status);
        }
      });
    }
  });

  testWidgets('LiveIndicator is silent unless it has a label', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpNeo(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiveIndicator(),
          LiveIndicator.ring(
            semanticLabel: 'Siren active',
            child: Icon(Icons.campaign_rounded),
          ),
        ],
      ),
    );

    expect(find.bySemanticsLabel('Siren active'), findsOneWidget);
    expect(find.byIcon(Icons.campaign_rounded), findsOneWidget);
    expect(tester.getSize(find.byType(LiveIndicator).first), const Size(8, 8));
    semantics.dispose();
  });

  testWidgets('NeoSectionHeader shows caps but reads as a normal heading',
      (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await pumpNeo(
      tester,
      SizedBox(
        width: 360,
        child: NeoSectionHeader(
          title: 'Recent reports',
          actionLabel: 'See all',
          onAction: () => taps++,
        ),
      ),
    );

    expect(find.text('RECENT REPORTS'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Recent reports')),
      isSemantics(label: 'Recent reports', isHeader: true),
    );
    await tester.tap(find.text('See all'));
    expect(taps, 1);
    semantics.dispose();
  });

  group('NeoListRow', () {
    testWidgets('is one tappable button with its title and subtitle',
        (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await pumpNeo(
        tester,
        SizedBox(
          width: 360,
          child: NeoListRow(
            icon: Icons.person_outline_rounded,
            title: 'Edit Personal Details',
            subtitle: 'Name, phone and address',
            onTap: () => taps++,
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      final node = tester.getSemantics(find.text('Edit Personal Details'));
      expect(node, isSemantics(isButton: true, hasTapAction: true));
      expect(node.label, contains('Name, phone and address'));

      await tester.tap(find.text('Edit Personal Details'));
      expect(taps, 1);
      semantics.dispose();
    });

    testWidgets('shows a trailing widget instead of the chevron',
        (tester) async {
      await pumpNeo(
        tester,
        SizedBox(
          width: 360,
          child: NeoListRow(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });
  });
}
