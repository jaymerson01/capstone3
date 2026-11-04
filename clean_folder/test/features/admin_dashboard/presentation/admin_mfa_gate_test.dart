import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/core/security/totp.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/admin_accounts_remote_data_source.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/admin_mfa_gate.dart';

class MockAccounts extends Mock implements AdminAccountsRemoteDataSource {}

const _panel = Text('ADMIN PANEL');
const _secret = 'JBSWY3DPEHPK3PXPJBSWY3DPEHPK3PXP';

void main() {
  late MockAccounts accounts;
  late int signOuts;

  setUp(() {
    AdminMfaGate.endSession();
    accounts = MockAccounts();
    signOuts = 0;
  });

  Future<void> pumpGate(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      home: AdminMfaGate(
        accounts: accounts,
        uid: 'admin_1',
        email: 'desk@resq.ph',
        onSignOut: () => signOuts++,
        child: _panel,
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String code) async {
    await tester.enterText(find.byKey(const Key('mfa-code')), code);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  testWidgets('first sign-in links the authenticator app, then opens the panel', (tester) async {
    when(() => accounts.mfaSecret('admin_1')).thenAnswer((_) async => null);
    when(() => accounts.enrollMfa(uid: any(named: 'uid'), email: any(named: 'email'), secret: any(named: 'secret')))
        .thenAnswer((_) async {});
    await pumpGate(tester);

    expect(find.text('Set up two-step verification'), findsOneWidget);
    expect(find.text('ADMIN PANEL'), findsNothing);

    await enter(tester, '000000');
    expect(find.textContaining('wrong or expired'), findsOneWidget);
    verifyNever(() => accounts.enrollMfa(uid: any(named: 'uid'), email: any(named: 'email'), secret: any(named: 'secret')));

    // The key shown for manual entry is the one behind the QR code.
    final shown = tester.widget<SelectableText>(find.byType(SelectableText)).data!.replaceAll(' ', '');
    await enter(tester, Totp.codeAt(shown, DateTime.now()));

    expect(find.text('ADMIN PANEL'), findsOneWidget);
    verify(() => accounts.enrollMfa(uid: 'admin_1', email: 'desk@resq.ph', secret: shown)).called(1);
  });

  testWidgets('later sign-ins ask for the code from the linked app', (tester) async {
    when(() => accounts.mfaSecret('admin_1')).thenAnswer((_) async => _secret);
    await pumpGate(tester);

    expect(find.text('Two-step verification'), findsOneWidget);
    expect(find.byType(SelectableText), findsNothing, reason: 'the key is never shown again');

    await enter(tester, Totp.codeAt(_secret, DateTime.now()));
    expect(find.text('ADMIN PANEL'), findsOneWidget);
    verifyNever(() => accounts.enrollMfa(uid: any(named: 'uid'), email: any(named: 'email'), secret: any(named: 'secret')));
  });

  testWidgets('signs the admin out after too many wrong codes', (tester) async {
    when(() => accounts.mfaSecret('admin_1')).thenAnswer((_) async => _secret);
    await pumpGate(tester);

    for (var i = 0; i < AdminMfaGate.maxAttempts; i++) {
      await enter(tester, '000000');
    }
    expect(signOuts, 1);
    expect(find.text('ADMIN PANEL'), findsNothing);
  });

  testWidgets('stays closed and explains when the rules are not deployed yet', (tester) async {
    when(() => accounts.mfaSecret('admin_1'))
        .thenThrow(FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'));
    await pumpGate(tester);

    expect(find.textContaining('database rules still need to be deployed'), findsOneWidget);
    expect(find.text('ADMIN PANEL'), findsNothing);
  });
}
