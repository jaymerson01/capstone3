import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/core/widgets/emergency_siren_alert.dart';

void main() {
  Future<void> pumpAlert(
    WidgetTester tester,
    Size size, {
    VoidCallback? onAcknowledge,
    String acknowledgeLabel = 'ACKNOWLEDGE ALERT',
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.resident(),
        home: EmergencySirenAlert(
          header: 'EMERGENCY SIREN NG MUNISIPYO',
          alertType: 'Emergency Siren',
          title: 'Municipal emergency advisory',
          message:
              'Pinapayuhan ng mga awtoridad ng Barangay ang agarang pag-iingat.',
          targetLabel: 'Sektor: Lahat ng Sektor',
          originLabel: 'Mula sa: Barangay Command Center',
          timeLabel: '9:30 AM',
          acknowledgeLabel: acknowledgeLabel,
          onAcknowledge: onAcknowledge ?? () {},
        ),
      ),
    );
  }

  testWidgets('shows the advisory and acknowledges on tap', (tester) async {
    var acknowledged = 0;
    await pumpAlert(
      tester,
      const Size(390, 844),
      onAcknowledge: () => acknowledged++,
    );

    for (final text in [
      'EMERGENCY SIREN NG MUNISIPYO',
      'Emergency Siren',
      'MUNICIPAL EMERGENCY ADVISORY',
      'Sektor: Lahat ng Sektor',
      'Mula sa: Barangay Command Center',
      '9:30 AM',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }

    await tester.ensureVisible(find.text('ACKNOWLEDGE ALERT'));
    await tester.tap(find.text('ACKNOWLEDGE ALERT'));
    expect(acknowledged, 1);
  });

  testWidgets('scrolls instead of overflowing on a small phone',
      (tester) async {
    await pumpAlert(
      tester,
      const Size(320, 568),
      acknowledgeLabel: 'KUMPIRMAHIN ANG ALERTO',
    );

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('KUMPIRMAHIN ANG ALERTO'));
    expect(find.text('KUMPIRMAHIN ANG ALERTO'), findsOneWidget);
  });
}
