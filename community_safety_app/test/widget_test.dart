import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:community_safety_app/main.dart';

void main() {
  testWidgets('Welcome page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CommunitySafetyApp());

    // Verify that the welcome page elements are present.
    expect(find.text('SAFE MOONWALK'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create an Account'), findsOneWidget);
  });
}

