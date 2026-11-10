import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_text_field.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';

Future<void> pumpInApp(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.resident(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('Custom3dButton', () {
    testWidgets('ignores a second tap within 600 ms', (tester) async {
      var presses = 0;
      await pumpInApp(
        tester,
        Custom3dButton(text: 'Submit Report', onPressed: () => presses++),
      );

      await tester.tap(find.text('Submit Report'));
      await tester.tap(find.text('Submit Report'));
      expect(presses, 1);

      // The guard uses the wall clock, so let real time pass.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 650)),
      );
      await tester.tap(find.text('Submit Report'));
      expect(presses, 2);
      await tester.pumpAndSettle();
    });

    testWidgets('does nothing without onPressed', (tester) async {
      await pumpInApp(
        tester,
        const Custom3dButton(text: 'Submit Report', onPressed: null),
      );

      await tester.tap(find.text('Submit Report'));
      await tester.pumpAndSettle();
      final label = tester.widget<Text>(find.text('Submit Report'));
      expect(label.style?.color?.a, closeTo(0.5, 0.01));
    });

    testWidgets('shows an optional edge for glass buttons', (tester) async {
      await pumpInApp(
        tester,
        Custom3dButton(
          text: 'Emergency Hotlines',
          backgroundColor: const Color(0xB30F172A),
          borderColor: Colors.white,
          onPressed: () {},
        ),
      );

      final edges = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .map((c) => (c.decoration as BoxDecoration?)?.border)
          .whereType<Border>();
      expect(edges.single.top.color, Colors.white);
    });
  });

  group('Custom3dTextField', () {
    testWidgets('keeps its usual look by default', (tester) async {
      await pumpInApp(
        tester,
        const Custom3dTextField(labelText: 'Full Name'),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.style?.color, AppColors.textDark);
    });

    testWidgets('uses light text and readable errors on glass', (tester) async {
      final form = GlobalKey<FormState>();
      await pumpInApp(
        tester,
        Form(
          key: form,
          child: Custom3dTextField(
            labelText: 'Email Address',
            onGlass: true,
            validator: (_) => 'Email is required.',
          ),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.style?.color, Colors.white);

      form.currentState!.validate();
      await tester.pump();
      final error = tester.widget<Text>(find.text('Email is required.'));
      expect(error.style?.color, AppColors.dangerLight);
    });
  });
}
