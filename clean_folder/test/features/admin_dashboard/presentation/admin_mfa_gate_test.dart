import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/security/totp.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/admin_accounts_remote_data_source.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/admin_mfa_gate.dart';

const _panel = Text('ADMIN PANEL');
const _secret = 'JBSWY3DPEHPK3PXPJBSWY3DPEHPK3PXP';

/// Stands in for the `adminMfa` Cloud Function: keeps the key "on the
/// server" and checks codes the way functions/totp.js does.
class FakeAccounts implements AdminAccountsRemoteDataSource {
  FakeAccounts({this.enrolledSecret});

  String? enrolledSecret;
  String? pendingSecret;
  int setupCalls = 0;
  final List<String> codesSent = [];

  /// When set, every call fails with this.
  AdminMfaException? failWith;

  @override
  Future<bool> mfaStatus() async {
    if (failWith != null) throw failWith!;
    return enrolledSecret != null;
  }

  @override
  Future<String> beginMfaSetup() async {
    if (failWith != null) throw failWith!;
    if (enrolledSecret != null) throw const AdminMfaException(AdminMfaFailure.setupState);
    setupCalls++;
    return pendingSecret = Totp.generateSecret();
  }

  @override
  Future<void> verifyMfaCode(String code) async {
    codesSent.add(code);
    if (failWith != null) throw failWith!;
    final secret = enrolledSecret ?? pendingSecret;
    if (secret == null) throw const AdminMfaException(AdminMfaFailure.setupState);
    if (!Totp.verify(secret, code)) throw const AdminMfaException(AdminMfaFailure.wrongCode);
    enrolledSecret = secret;
    pendingSecret = null;
  }

  @override
  Future<void> resetMfa(String uid) async {}

  @override
  Future<String> createStaffAccount({
    required String email,
    required String displayName,
    String role = 'admin',
    String? department,
  }) =>
      throw UnimplementedError();
}

void main() {
  late FakeAccounts accounts;
  late int signOuts;

  setUp(() {
    AdminMfaGate.endSession();
    accounts = FakeAccounts();
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

  testWidgets('first sign-in links the authenticator app with a server-made key, then opens the panel',
      (tester) async {
    await pumpGate(tester);

    expect(find.text('Set up two-step verification'), findsOneWidget);
    expect(find.text('ADMIN PANEL'), findsNothing);
    expect(accounts.setupCalls, 1);

    // The key shown for manual entry is the one the server made.
    final shown = tester.widget<SelectableText>(find.byType(SelectableText)).data!.replaceAll(' ', '');
    expect(shown, accounts.pendingSecret);

    await enter(tester, '000000');
    expect(find.textContaining('wrong or expired'), findsOneWidget);
    expect(accounts.enrolledSecret, isNull);

    await enter(tester, Totp.codeAt(shown, DateTime.now()));
    expect(find.text('ADMIN PANEL'), findsOneWidget);
    expect(accounts.enrolledSecret, shown);
  });

  testWidgets('later sign-ins send the code to the server, never showing the key', (tester) async {
    accounts.enrolledSecret = _secret;
    await pumpGate(tester);

    expect(find.text('Two-step verification'), findsOneWidget);
    expect(find.byType(SelectableText), findsNothing, reason: 'the key is never shown again');
    expect(accounts.setupCalls, 0);

    final code = Totp.codeAt(_secret, DateTime.now());
    await enter(tester, code);
    expect(find.text('ADMIN PANEL'), findsOneWidget);
    expect(accounts.codesSent, [code]);
  });

  testWidgets('an incomplete code is not sent', (tester) async {
    accounts.enrolledSecret = _secret;
    await pumpGate(tester);

    await enter(tester, '123');
    expect(find.textContaining('6-digit code from your authenticator'), findsOneWidget);
    expect(accounts.codesSent, isEmpty);
  });

  testWidgets('signs the admin out after too many wrong codes', (tester) async {
    accounts.enrolledSecret = _secret;
    await pumpGate(tester);

    for (var i = 0; i < AdminMfaGate.maxAttempts; i++) {
      await enter(tester, '000000');
    }
    expect(signOuts, 1);
    expect(find.text('ADMIN PANEL'), findsNothing);
  });

  testWidgets('explains a server lock-out and stays closed', (tester) async {
    accounts.enrolledSecret = _secret;
    await pumpGate(tester);

    accounts.failWith = const AdminMfaException(AdminMfaFailure.lockedOut);
    await enter(tester, Totp.codeAt(_secret, DateTime.now()));

    expect(find.textContaining('Too many wrong codes. Wait 15 minutes'), findsOneWidget);
    expect(find.byKey(const Key('mfa-code')), findsNothing);
    expect(find.text('ADMIN PANEL'), findsNothing);
  });

  testWidgets('stays closed and explains when the server is not deployed or unreachable', (tester) async {
    accounts
      ..enrolledSecret = _secret
      ..failWith = const AdminMfaException(AdminMfaFailure.unavailable);
    await pumpGate(tester);

    expect(find.textContaining('may not be deployed yet'), findsOneWidget);
    expect(find.text('ADMIN PANEL'), findsNothing);

    // Once it is reachable, "Try again" carries on to the code step.
    accounts.failWith = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mfa-code')), findsOneWidget);
  });

  testWidgets('an unreachable server while checking a code does not count as a wrong code', (tester) async {
    accounts.enrolledSecret = _secret;
    await pumpGate(tester);

    accounts.failWith = const AdminMfaException(AdminMfaFailure.unavailable);
    for (var i = 0; i < AdminMfaGate.maxAttempts; i++) {
      await enter(tester, '000000');
    }
    expect(find.textContaining('may not be deployed yet'), findsOneWidget);
    expect(signOuts, 0);
  });

  testWidgets('refuses accounts the server says are not admins', (tester) async {
    accounts.failWith = const AdminMfaException(AdminMfaFailure.notAllowed);
    await pumpGate(tester);

    expect(find.textContaining("can't use the admin portal"), findsOneWidget);
    expect(find.text('ADMIN PANEL'), findsNothing);
  });
}
