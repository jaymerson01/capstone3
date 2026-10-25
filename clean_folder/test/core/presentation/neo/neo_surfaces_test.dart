import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/presentation/neo/aurora_background.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/landscape_backdrop.dart';
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

void main() {
  tearDown(() => AppColors.isDarkMode = false);

  testWidgets('AuroraBackground paints behind its child in both modes',
      (tester) async {
    for (final dark in [false, true]) {
      AppColors.isDarkMode = dark;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.resident(),
          home: const AuroraBackground(child: Text('Home')),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(AuroraBackground)), const Size(800, 600));
    }
  });

  testWidgets('LandscapeBackdrop draws the phone and desktop scenes',
      (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    for (final size in const [Size(390, 844), Size(1440, 900)]) {
      tester.view.physicalSize = size;
      for (final time in LandscapeTime.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: LandscapeBackdrop(time: time, child: const Text('Sign in')),
          ),
        );

        expect(find.text('Sign in'), findsOneWidget, reason: '$time $size');
        expect(tester.takeException(), isNull, reason: '$time $size');
      }
    }
  });

  testWidgets('GlassCard shows its child and reports taps', (tester) async {
    var taps = 0;
    await pumpNeo(
      tester,
      GlassCard(onTap: () => taps++, child: const Text('Report details')),
    );

    await tester.tap(find.text('Report details'));
    expect(taps, 1);
  });

  testWidgets('GlassCard blurs only when asked', (tester) async {
    await pumpNeo(tester, const GlassCard(child: Text('List card')));
    expect(find.byType(BackdropFilter), findsNothing);

    await pumpNeo(
      tester,
      const GlassCard(
        blur: true,
        tone: GlassTone.smoke,
        child: Text('Sign in panel'),
      ),
    );
    expect(find.text('Sign in panel'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
