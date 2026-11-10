import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/presentation/neo/word_safe_text.dart';

const TextStyle style = TextStyle(fontSize: 20, height: 1.0);

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: DefaultTextStyle(style: style, child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('text that fits lays out like plain Text', (tester) async {
    await _pump(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 300, child: WordSafeText('Fire Incident')),
          SizedBox(width: 300, child: Text('Fire Incident')),
        ],
      ),
    );

    expect(
      tester.getSize(find.byType(WordSafeText)),
      tester.getSize(find.text('Fire Incident').last),
    );
  });

  testWidgets('a word too wide for the space shrinks instead of breaking',
      (tester) async {
    // The test font draws every letter 1em wide, so this word is 200px.
    await _pump(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 160, child: WordSafeText('Pagnanakaw')),
          SizedBox(width: 160, child: Text('Pagnanakaw')),
        ],
      ),
    );

    final safe = tester.getSize(find.byType(WordSafeText));
    final plain = tester.getSize(find.text('Pagnanakaw').last);
    // Plain Text splits the word over two lines; WordSafeText keeps one.
    expect(plain.height, 40);
    expect(safe.height, lessThan(20));
    expect(safe.width, lessThanOrEqualTo(160));
  });

  testWidgets('a hyphenated word wraps at the hyphen instead of shrinking',
      (tester) async {
    // "Kahina-" is 140px and "hinalang" 160px, so each half fits 170px.
    await _pump(
      tester,
      const SizedBox(width: 170, child: WordSafeText('Kahina-hinalang')),
    );

    final text = tester.widget<Text>(find.text('Kahina-hinalang'));
    expect(text.style?.fontSize, 20);
    expect(tester.getSize(find.byType(WordSafeText)).height, 40);
  });

  testWidgets('it still wraps between words and honours maxLines',
      (tester) async {
    // Every word fits 200px (the longest is 180px), so nothing shrinks.
    await _pump(
      tester,
      const SizedBox(
        width: 200,
        child: WordSafeText(
          'Mga Emergency Hotline ng Barangay',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    // Two lines of 20px, never a third.
    expect(tester.getSize(find.byType(WordSafeText)).height, 40);
  });

  testWidgets('it works inside an IntrinsicHeight row of tiles',
      (tester) async {
    await _pump(
      tester,
      const SizedBox(
        width: 200,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: WordSafeText('Medikal na Emergency')),
              Expanded(child: WordSafeText('Pagnanakaw / Holdap')),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(WordSafeText), findsNWidgets(2));
  });

  testWidgets('screen readers read the full text', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      const SizedBox(width: 60, child: WordSafeText('Kahina-hinalang Gawain')),
    );

    expect(find.bySemanticsLabel('Kahina-hinalang Gawain'), findsOneWidget);
    semantics.dispose();
  });
}
