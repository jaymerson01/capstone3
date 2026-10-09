import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:main_folder/pages/welcome_page.dart';

void main() {
  testWidgets('Welcome page smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomePage()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(WelcomePage), findsOneWidget);
  });
}

