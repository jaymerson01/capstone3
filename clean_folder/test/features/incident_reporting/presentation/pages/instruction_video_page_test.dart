import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/instruction_video_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('both guide videos ship with the app', () async {
    for (final lang in ['en', 'fil']) {
      final video =
          await rootBundle.load(InstructionVideoPage.assetFor(Locale(lang)));
      expect(video.lengthInBytes, greaterThan(1000000), reason: lang);
    }
  });

  test('plays the guide in the app language', () {
    expect(InstructionVideoPage.assetFor(const Locale('fil')),
        'assets/videos/how_to_use_fil.mp4');
    expect(InstructionVideoPage.assetFor(const Locale('en')),
        'assets/videos/how_to_use_en.mp4');
  });

  test('falls back to English for other languages', () {
    expect(InstructionVideoPage.assetFor(const Locale('ja')),
        'assets/videos/how_to_use_en.mp4');
  });

  testWidgets('shows a message when the video cannot play, then closes',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.resident(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InstructionVideoPage()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Widget tests have no video plugin, so loading fails like a bad file.
    expect(find.text('Unable to stream video in-app'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byTooltip('Play'), findsNothing);

    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(InstructionVideoPage), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });
}
