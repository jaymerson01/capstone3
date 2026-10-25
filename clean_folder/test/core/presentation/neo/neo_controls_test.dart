import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/presentation/neo/neo_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_chip.dart';
import 'package:community_safety_app/core/presentation/neo/neo_icon_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_segmented.dart';
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

  group('NeoButton', () {
    testWidgets('calls onPressed and reads as an enabled button',
        (tester) async {
      final semantics = tester.ensureSemantics();
      var presses = 0;
      await pumpNeo(
        tester,
        NeoButton(label: 'Submit Report', onPressed: () => presses++),
      );

      await tester.tap(find.text('Submit Report'));
      await tester.pumpAndSettle();
      expect(presses, 1);
      expect(
        tester.getSemantics(find.text('Submit Report')),
        isSemantics(
          label: 'Submit Report',
          isButton: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('is disabled without onPressed', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpNeo(
        tester,
        const NeoButton(label: 'Submit Report', onPressed: null),
      );

      expect(
        tester.getSemantics(find.text('Submit Report')),
        isSemantics(isButton: true, isEnabled: false, hasTapAction: false),
      );
      semantics.dispose();
    });

    testWidgets('shows its icon and can fill the width', (tester) async {
      await pumpNeo(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeoButton(
              label: 'Call 911',
              variant: NeoButtonVariant.emergency,
              icon: Icons.call,
              onPressed: () {},
            ),
            NeoButton(
              label: 'Cancel',
              variant: NeoButtonVariant.standard,
              expand: true,
              onPressed: () {},
            ),
          ],
        ),
      );

      expect(find.byIcon(Icons.call), findsOneWidget);
      expect(tester.getSize(find.byType(NeoButton).last).width, 800);
    });

    testWidgets('renders every variant in dark mode', (tester) async {
      AppColors.isDarkMode = true;
      await pumpNeo(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final variant in NeoButtonVariant.values)
              NeoButton(label: variant.name, variant: variant, onPressed: () {}),
          ],
        ),
      );

      for (final variant in NeoButtonVariant.values) {
        expect(find.text(variant.name), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('NeoIconButton announces its tooltip and calls back',
      (tester) async {
    final semantics = tester.ensureSemantics();
    var presses = 0;
    await pumpNeo(
      tester,
      NeoIconButton(
        icon: Icons.photo_camera_outlined,
        tooltip: 'Take photo',
        tone: NeoIconButtonTone.slate,
        onPressed: () => presses++,
      ),
    );

    await tester.tap(find.byIcon(Icons.photo_camera_outlined));
    expect(presses, 1);
    expect(
      tester.getSemantics(find.byIcon(Icons.photo_camera_outlined)),
      isSemantics(tooltip: 'Take photo', isButton: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('NeoChip reads as selected or not, and calls back',
      (tester) async {
    final semantics = tester.ensureSemantics();
    var presses = 0;
    await pumpNeo(
      tester,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeoChip(label: 'Fire', selected: true, onPressed: () => presses++),
          NeoChip(label: 'Flood', selected: false, onPressed: () {}),
        ],
      ),
    );

    await tester.tap(find.text('Fire'));
    expect(presses, 1);
    expect(
      tester.getSemantics(find.text('Fire')),
      isSemantics(label: 'Fire', isButton: true, isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('Flood')),
      isSemantics(label: 'Flood', isButton: true, isSelected: false),
    );
    semantics.dispose();
  });

  testWidgets('NeoSegmented marks the choice and reports changes',
      (tester) async {
    final semantics = tester.ensureSemantics();
    String? changed;
    await pumpNeo(
      tester,
      SizedBox(
        width: 320,
        child: NeoSegmented<String>(
          segments: const [
            NeoSegment(value: 'self', label: 'Myself'),
            NeoSegment(value: 'other', label: 'For Someone'),
          ],
          selected: 'self',
          onChanged: (value) => changed = value,
        ),
      ),
    );

    expect(
      tester.getSemantics(find.text('Myself')),
      isSemantics(
        isButton: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('For Someone')),
      isSemantics(isButton: true, isSelected: false),
    );

    await tester.tap(find.text('For Someone'));
    expect(changed, 'other');
    semantics.dispose();
  });
}
