import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_safety_app/core/services/first_run_guide.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/instruction_video_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/widgets/first_run_guide_gate.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

Widget _app() => MaterialApp(
      theme: AppTheme.resident(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const FirstRunGuideGate(child: Scaffold(body: Text('welcome screen'))),
    );

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('opens the guide the first time, then never by itself again',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await FirstRunGuide.load();
    expect(FirstRunGuide.pending, isTrue);

    await tester.pumpWidget(_app());
    await _settle(tester);

    final guide = tester.widget<InstructionVideoPage>(find.byType(InstructionVideoPage));
    expect(guide.firstRun, isTrue);
    expect(find.text("Welcome! Here's how ResQ works"), findsOneWidget);
    expect(find.byTooltip('Close'), findsNothing);

    await tester.tap(find.byKey(const Key('guide-skip')));
    await _settle(tester);
    expect(find.byType(InstructionVideoPage), findsNothing);
    expect(find.text('welcome screen'), findsOneWidget);
    expect(FirstRunGuide.pending, isFalse);

    // Next launch: the saved flag keeps it closed.
    await FirstRunGuide.load();
    expect(FirstRunGuide.pending, isFalse);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app());
    await _settle(tester);
    expect(find.byType(InstructionVideoPage), findsNothing);
  });

  testWidgets('can always be left with Get started, even if the video fails',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await FirstRunGuide.load();

    await tester.pumpWidget(_app());
    await _settle(tester);

    // Widget tests have no video plugin, so loading fails like a bad file.
    expect(find.text('Unable to stream video in-app'), findsOneWidget);
    await tester.tap(find.byKey(const Key('guide-start')));
    await _settle(tester);
    expect(find.byType(InstructionVideoPage), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('first_run_guide_seen'), isTrue);
  });

  testWidgets('stays closed for someone who has already seen it', (tester) async {
    SharedPreferences.setMockInitialValues({'first_run_guide_seen': true});
    await FirstRunGuide.load();

    await tester.pumpWidget(_app());
    await _settle(tester);
    expect(find.byType(InstructionVideoPage), findsNothing);
    expect(find.text('welcome screen'), findsOneWidget);
  });

  testWidgets('shows Filipino buttons in Filipino', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await FirstRunGuide.load();

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('fil'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const FirstRunGuideGate(child: SizedBox()),
    ));
    await _settle(tester);
    expect(find.text('Laktawan'), findsOneWidget);
    expect(find.text('Simulan na'), findsOneWidget);
  });
}
