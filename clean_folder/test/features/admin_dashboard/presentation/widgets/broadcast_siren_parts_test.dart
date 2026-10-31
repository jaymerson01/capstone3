import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/broadcast_siren_parts.dart';

const _types = [
  'Fire Alarm',
  'Flood Evacuation',
  'Earthquake Advisory',
  'Severe Weather',
  'Security Curfew',
  'General Notice',
];

const _sectors = {
  'All Barangay Moonwalk': 'All Moonwalk',
  'Area 1 - San Jose': 'Area 1',
  'Area 2 - Airborne': 'Area 2',
};

/// Records what the broadcast dialog parts report back.
class _Log {
  final events = <String>[];
  void call(String event) => events.add(event);
}

Widget _form(_Log log, {bool busy = false}) {
  return BroadcastTransmitForm(
    titleController: TextEditingController(),
    messageController: TextEditingController(),
    alertTypes: _types,
    alertType: 'Fire Alarm',
    onAlertTypeChanged: (v) => log('type $v'),
    sectors: _sectors,
    sector: 'All Barangay Moonwalk',
    onSectorChanged: (v) => log('sector $v'),
    busy: busy,
    onTransmit: () => log('transmit'),
  );
}

Widget _card(_Log log) {
  return ActiveSirenCard(
    type: 'Flood Evacuation',
    title: 'Flash flood advisory',
    sector: 'All Barangay Moonwalk',
    message: 'Move to higher ground.',
    timeLabel: '9:30 AM',
    onSilence: () => log('silence'),
    onDelete: () => log('delete'),
  );
}

Future<void> _pumpPanel(
  WidgetTester tester,
  _Log log, {
  required Size size,
  int tab = 0,
  bool empty = false,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.admin(),
      home: Scaffold(
        body: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: BroadcastSirenPanel(
            tab: tab,
            onTabChanged: (t) => log('tab $t'),
            onClose: () => log('close'),
            activeSirens: (context, sideBySide) => empty
                ? SirensClearNotice(
                    onTransmitNew: sideBySide ? null : () => log('tab 1'),
                  )
                : _card(log),
            transmitForm: _form(log),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('wide screens show the sirens and the form side by side', (
    tester,
  ) async {
    final log = _Log();
    await _pumpPanel(tester, log, size: const Size(1440, 900));

    expect(find.text('Municipal Emergency Broadcast'), findsOneWidget);
    expect(find.text('ACTIVE SIRENS'), findsOneWidget);
    expect(find.text('Flash flood advisory'), findsOneWidget);
    expect(find.text('TRANSMIT NEW ALERT'), findsOneWidget);
    expect(find.text('Transmit New'), findsNothing); // no tabs
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Close'));
    expect(log.events, ['close']);
  });

  testWidgets('narrow screens switch between the sirens and the form', (
    tester,
  ) async {
    final log = _Log();
    await _pumpPanel(tester, log, size: const Size(390, 844));

    expect(find.text('Flash flood advisory'), findsOneWidget);
    expect(find.text('TRANSMIT NEW ALERT'), findsNothing);
    await tester.tap(find.text('Transmit New'));
    expect(log.events, ['tab 1']);

    await _pumpPanel(tester, log, size: const Size(390, 844), tab: 1);
    expect(find.text('Flash flood advisory'), findsNothing);
    expect(find.text('TRANSMIT NEW ALERT'), findsOneWidget);
    await tester.tap(find.text('Active Sirens'));
    expect(log.events, ['tab 1', 'tab 0']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the all-clear notice links to the form only behind a tab', (
    tester,
  ) async {
    final log = _Log();
    await _pumpPanel(tester, log, size: const Size(1440, 900), empty: true);
    expect(find.text('All Municipal Sectors Clear'), findsOneWidget);
    expect(find.text('Transmit New Alert'), findsNothing);

    await _pumpPanel(tester, log, size: const Size(390, 844), empty: true);
    await tester.tap(find.text('Transmit New Alert'));
    expect(log.events, ['tab 1']);
  });

  testWidgets('ActiveSirenCard silences and deletes', (tester) async {
    final log = _Log();
    await _pumpPanel(tester, log, size: const Size(1440, 900));

    await tester.tap(find.text('SILENCE & CLEAR SIREN'));
    await tester.tap(find.byTooltip('Delete Record'));
    expect(log.events, ['silence', 'delete']);
  });

  testWidgets('BroadcastTransmitForm picks a type and sector, then transmits', (
    tester,
  ) async {
    final log = _Log();
    await _pumpPanel(tester, log, size: const Size(1440, 900), tab: 1);

    for (final type in _types) {
      expect(
        find.descendant(
          of: find.byType(BroadcastTransmitForm),
          matching: find.text(type),
        ),
        findsOneWidget,
      );
    }
    await tester.tap(find.text('Severe Weather'));

    await tester.tap(find.text('All Moonwalk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Area 2').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('TRANSMIT SIREN BROADCAST'));
    expect(log.events, [
      'type Severe Weather',
      'sector Area 2 - Airborne',
      'transmit',
    ]);
  });

  testWidgets('a busy transmit button shows progress and ignores taps', (
    tester,
  ) async {
    final log = _Log();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.admin(),
        home: Scaffold(
          body: SingleChildScrollView(child: _form(log, busy: true)),
        ),
      ),
    );

    expect(find.text('TRANSMIT SIREN BROADCAST'), findsNothing);
    final button = find.text('TRANSMITTING...');
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
    expect(log.events, isEmpty);
  });
}
