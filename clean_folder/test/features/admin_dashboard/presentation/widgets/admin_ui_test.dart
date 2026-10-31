import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.admin(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('AdminButton taps, disables and shows progress', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      AdminButton(label: 'Save', icon: Icons.save, onPressed: () => taps++),
    );
    await tester.tap(find.text('Save'));
    expect(taps, 1);

    await _pump(tester, const AdminButton(label: 'Save', onPressed: null));
    await tester.tap(find.text('Save'));
    expect(taps, 1);

    await _pump(
      tester,
      AdminButton(label: 'Save', busy: true, onPressed: () => taps++),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Save'));
    expect(taps, 1);
  });

  testWidgets('every AdminButton style lays out in a narrow space', (
    tester,
  ) async {
    for (final style in AdminButtonStyle.values) {
      await _pump(
        tester,
        SizedBox(
          width: 120,
          child: AdminButton(
            label: 'Save & Broadcast Status',
            icon: Icons.send,
            style: style,
            expand: true,
            onPressed: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: '$style');
    }
  });

  testWidgets('AdminSegmented reports the tapped segment', (tester) async {
    final semantics = tester.ensureSemantics();
    String? picked;
    await _pump(
      tester,
      AdminSegmented<String>(
        segments: const [('all', 'All'), ('active', 'Active')],
        value: 'all',
        onChanged: (v) => picked = v,
      ),
    );

    expect(
      tester.getSemantics(find.text('All')),
      isSemantics(isButton: true, isSelected: true),
    );
    await tester.tap(find.text('Active'));
    expect(picked, 'active');
    semantics.dispose();
  });

  testWidgets('AdminSelect shows the label and reports a new value', (
    tester,
  ) async {
    int? picked;
    await _pump(
      tester,
      AdminSelect<int>(
        value: 1,
        items: const [(1, 'All Statuses'), (2, 'Pending')],
        onChanged: (v) => picked = v,
      ),
    );

    expect(find.text('All Statuses'), findsOneWidget);
    await tester.tap(find.text('All Statuses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pending').last);
    await tester.pumpAndSettle();
    expect(picked, 2);
  });

  testWidgets('AdminChoiceTile and AdminChoiceChip report taps and state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await _pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdminChoiceTile(
            label: 'In Progress (Unit Dispatched)',
            selected: true,
            onTap: () => taps++,
          ),
          AdminChoiceChip(
            label: '10-15 mins',
            selected: false,
            onTap: () => taps++,
          ),
        ],
      ),
    );

    expect(
      tester.getSemantics(find.text('In Progress (Unit Dispatched)')),
      isSemantics(isChecked: true, isInMutuallyExclusiveGroup: true),
    );
    await tester.tap(find.text('In Progress (Unit Dispatched)'));
    await tester.tap(find.text('10-15 mins'));
    expect(taps, 2);
    semantics.dispose();
  });

  testWidgets('AdminDialog shows its parts and closes', (tester) async {
    var closed = 0;
    var saved = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.admin(),
        home: Scaffold(
          body: AdminDialog(
            title: 'Edit Status',
            subtitle: 'Fire Incident',
            icon: Icons.edit_note_rounded,
            tone: AdminTone.cyan,
            onClose: () => closed++,
            actions: [
              AdminButton(
                label: 'Cancel',
                style: AdminButtonStyle.ghost,
                onPressed: () => closed++,
              ),
              AdminButton(label: 'Save', onPressed: () => saved++),
            ],
            child: const Text('Resolution stage'),
          ),
        ),
      ),
    );

    expect(find.text('Edit Status'), findsOneWidget);
    expect(find.text('Fire Incident'), findsOneWidget);
    expect(find.text('Resolution stage'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.tap(find.text('Cancel'));
    await tester.tap(find.text('Save'));
    expect((closed, saved), (2, 1));
  });

  testWidgets('AdminSearchField reports typing', (tester) async {
    String? typed;
    await _pump(
      tester,
      SizedBox(
        width: 320,
        child: AdminSearchField(
          hint: 'Search by ID, type, reporter, location...',
          onChanged: (v) => typed = v,
        ),
      ),
    );

    expect(
      find.text('Search by ID, type, reporter, location...'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'fire');
    expect(typed, 'fire');
  });

  testWidgets('AdminPill and AdminIconAction render every tone', (
    tester,
  ) async {
    for (final tone in AdminTone.values) {
      await _pump(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdminPill(label: tone.name.toUpperCase(), tone: tone),
            AdminPill(label: 'SOLID', tone: tone, solid: true),
            AdminIconAction(
              icon: Icons.visibility_outlined,
              tooltip: 'View Details',
              tone: tone,
              onPressed: () {},
            ),
          ],
        ),
      );
      expect(find.text(tone.name.toUpperCase()), findsOneWidget);
      expect(find.byTooltip('View Details'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: '$tone');
    }
  });
}
