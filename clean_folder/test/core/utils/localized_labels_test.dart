import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/utils/localized_labels.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

/// Pumps a widget in [locale] and hands back a context that has translations.
Future<BuildContext> contextFor(WidgetTester tester, Locale locale) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(builder: (context) {
        captured = context;
        return const SizedBox();
      }),
    ),
  );
  return captured;
}

void main() {
  const english = Locale('en');
  const filipino = Locale('fil');

  group('category', () {
    testWidgets('translates the stored English categories', (tester) async {
      final context = await contextFor(tester, filipino);
      expect(LocalizedLabels.category(context, 'Fire Incident'), 'Sunog');
      expect(LocalizedLabels.category(context, 'Flood / Calamity'), 'Baha / Kalamidad');
    });

    testWidgets('keeps the text a resident typed for "Other Emergency"', (tester) async {
      final context = await contextFor(tester, filipino);
      expect(
        LocalizedLabels.category(context, 'Other Emergency (Gas Leak)'),
        'Ibang Emergency (Gas Leak)',
      );
    });

    testWidgets('leaves unknown categories untouched', (tester) async {
      final context = await contextFor(tester, filipino);
      expect(LocalizedLabels.category(context, 'Stray Animal'), 'Stray Animal');
    });

    testWidgets('shows the stored value unchanged in English', (tester) async {
      final context = await contextFor(tester, english);
      expect(LocalizedLabels.category(context, 'Road Accident'), 'Road Accident');
    });
  });

  testWidgets('status understands every stored spelling', (tester) async {
    final context = await contextFor(tester, filipino);
    expect(LocalizedLabels.status(context, 'Pending'), 'Nakabinbin');
    expect(LocalizedLabels.status(context, 'in_progress'), 'Inaaksyunan');
    expect(LocalizedLabels.status(context, 'in progress'), 'Inaaksyunan');
    expect(LocalizedLabels.status(context, 'solved'), 'Naresolba na');
  });

  testWidgets('urgency translates codes and keeps unknown values', (tester) async {
    final context = await contextFor(tester, filipino);
    expect(LocalizedLabels.urgency(context, 'CRITICAL'), 'Kritikal');
    expect(LocalizedLabels.urgency(context, 'medium'), 'Katamtaman');
    expect(LocalizedLabels.urgency(context, 'UNKNOWN'), 'UNKNOWN');
    expect(LocalizedLabels.urgency(context, null), '');
  });

  group('relativeTime', () {
    final now = DateTime(2026, 10, 24, 12, 0);

    testWidgets('uses English plurals', (tester) async {
      final context = await contextFor(tester, english);
      String ago(Duration d) =>
          LocalizedLabels.relativeTime(context, now.subtract(d), now: now);
      expect(ago(const Duration(seconds: 20)), 'just now');
      expect(ago(const Duration(minutes: 1)), '1 min ago');
      expect(ago(const Duration(minutes: 5)), '5 mins ago');
      expect(ago(const Duration(hours: 2)), '2 hrs ago');
      expect(ago(const Duration(days: 1)), '1 day ago');
    });

    testWidgets('uses Filipino wording', (tester) async {
      final context = await contextFor(tester, filipino);
      String ago(Duration d) =>
          LocalizedLabels.relativeTime(context, now.subtract(d), now: now);
      expect(ago(const Duration(seconds: 20)), 'ngayon lang');
      expect(ago(const Duration(minutes: 5)), '5 minuto ang nakalipas');
      expect(ago(const Duration(days: 3)), '3 araw ang nakalipas');
    });
  });
}
