import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/presentation/pages/terms_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class FakeStore extends TermsAcceptanceStore {
  FakeStore({this.onDevice = false});
  final bool onDevice;
  final List<String> accepted = [];

  @override
  bool acceptedOnDevice(String uid) => onDevice;

  @override
  Future<void> accept(String uid) async => accepted.add(uid);
}

const _home = Text('RESIDENT HOME');

void main() {
  late int declines;

  Future<void> pumpGate(WidgetTester tester, {required UserEntity user, required FakeStore store}) async {
    declines = 0;
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: TermsGate(user: user, store: store, onDecline: () => declines++, child: _home),
    ));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('a new resident must tick the box and accept first', (tester) async {
    final store = FakeStore();
    await pumpGate(tester, user: const UserEntity(id: 'r1', email: 'juan@gmail.com'), store: store);

    expect(find.text('Terms and Conditions'), findsOneWidget);
    expect(find.text('RESIDENT HOME'), findsNothing);

    await tester.tap(find.text('Accept and continue'));
    await tester.pump();
    expect(store.accepted, isEmpty, reason: 'disabled until the box is ticked');

    await tester.tap(find.byKey(const Key('terms-agree')));
    await tester.pump();
    await tester.tap(find.text('Accept and continue'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(store.accepted, ['r1']);
    expect(find.text('RESIDENT HOME'), findsOneWidget);
  });

  testWidgets('declining signs the resident out', (tester) async {
    await pumpGate(tester, user: const UserEntity(id: 'r1', email: 'juan@gmail.com'), store: FakeStore());
    await tester.tap(find.text('Decline and sign out'));
    expect(declines, 1);
  });

  testWidgets('skips the terms once this version is accepted', (tester) async {
    await pumpGate(
      tester,
      user: const UserEntity(id: 'r1', email: 'juan@gmail.com', acceptedTermsVersion: TermsAndConditions.version),
      store: FakeStore(),
    );
    expect(find.text('RESIDENT HOME'), findsOneWidget);

    await pumpGate(tester, user: const UserEntity(id: 'r2', email: 'ana@gmail.com'), store: FakeStore(onDevice: true));
    expect(find.text('RESIDENT HOME'), findsOneWidget, reason: 'accepted earlier while offline');
  });

  testWidgets('an older accepted version asks again', (tester) async {
    await pumpGate(
      tester,
      user: const UserEntity(id: 'r1', email: 'juan@gmail.com', acceptedTermsVersion: '2025-01'),
      store: FakeStore(),
    );
    expect(find.text('RESIDENT HOME'), findsNothing);
  });
}
