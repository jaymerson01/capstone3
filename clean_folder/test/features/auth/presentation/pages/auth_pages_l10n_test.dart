import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/core/utils/localized_labels.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/auth/presentation/pages/login_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

const filipino = Locale('fil');

void main() {
  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(Unauthenticated());
  });

  Future<void> pumpPage(WidgetTester tester, Widget page, Locale locale) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: page,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
  }

  group('authError', () {
    testWidgets('translates known Firebase codes', (tester) async {
      late BuildContext context;
      await pumpPage(
        tester,
        Builder(builder: (c) {
          context = c;
          return const SizedBox();
        }),
        filipino,
      );
      expect(
        LocalizedLabels.authError(context,
            code: 'invalid-credential', message: 'The supplied auth credential is incorrect'),
        'Mali ang email o password. Subukan ulit.',
      );
      expect(
        LocalizedLabels.authError(context, code: 'some-new-code', message: 'Firebase text'),
        'Firebase text',
      );
      expect(LocalizedLabels.authError(context, message: 'No code'), 'No code');
    });
  });

  testWidgets('Login screen and its validation are in Filipino', (tester) async {
    await pumpPage(tester, const LoginPage(), filipino);

    expect(find.text('MAG-SIGN IN'), findsOneWidget);
    expect(find.text('Nakalimutan ang Password?'), findsOneWidget);

    await tester.ensureVisible(find.text('MAGPATULOY'));
    await tester.tap(find.text('MAGPATULOY'));
    await tester.pump();

    expect(find.text('Kailangan ang email.'), findsOneWidget);
    expect(find.text('Kailangan ang password.'), findsOneWidget);
  });

  testWidgets('Firebase login errors are shown in Filipino', (tester) async {
    whenListen(
      authBloc,
      Stream<AuthState>.fromIterable([
        const AuthError('The supplied auth credential is incorrect.', code: 'invalid-credential'),
      ]),
      initialState: Unauthenticated(),
    );
    await pumpPage(tester, const LoginPage(), filipino);
    await tester.pump();

    expect(find.text('Mali ang email o password. Subukan ulit.'), findsOneWidget);
  });

  testWidgets('Welcome dialog is translated but keeps its automation id', (tester) async {
    await pumpPage(tester, const WelcomePage(), filipino);

    expect(find.text('Mga Emergency Hotline'), findsOneWidget);
    await tester.ensureVisible(find.text('Mag-ulat ng Insidente'));
    await tester.tap(find.text('Mag-ulat ng Insidente'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Kailangang Mag-login'), findsOneWidget);
    // The UI automation scripts find this button by its semantics label.
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'dialog_button_Login',
      ),
      findsOneWidget,
    );
  });
}
