import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/auth/presentation/pages/email_verification_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/login_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:community_safety_app/features/auth/presentation/widgets/auth_modals.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

const filipino = Locale('fil');

/// The ids the UI automation scripts use to find the sign-in controls.
Finder automationId(String id) => find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == id,
    );

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() => registerFallbackValue(const LogoutRequested()));

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(Unauthenticated());
  });

  tearDown(() => AppColors.isDarkMode = false);

  // A phone-sized screen, so the restyled layouts are checked at real width.
  Future<void> pumpPage(
    WidgetTester tester,
    Widget page, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp(
          theme: AppTheme.resident(),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: page,
          routes: {
            '/welcome': (_) => const Scaffold(body: Text('welcome route')),
          },
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
  }

  // The pages animate forever (pulsing rings), so pumpAndSettle would never
  // return: one frame to start a route change, then time for it to finish.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  List<AuthEvent> sentEvents() =>
      verify(() => authBloc.add(captureAny())).captured.cast<AuthEvent>();

  group('Welcome', () {
    testWidgets('keeps its automation id and opens Login', (tester) async {
      await pumpPage(tester, const WelcomePage());

      expect(automationId('nav_login_button'), findsOneWidget);
      expect(find.text('RESQ'), findsOneWidget);
      expect(find.text('SMART BARANGAY COMMAND SYSTEM'), findsOneWidget);

      await tester.tap(find.text('Login'));
      await settle(tester);
      expect(find.text('SIGN IN'), findsOneWidget);
    });

    testWidgets('lays out in Filipino at night without errors', (tester) async {
      AppColors.isDarkMode = true;
      await pumpPage(tester, const WelcomePage(), locale: filipino);

      expect(find.text('Mag-ulat ng Insidente'), findsOneWidget);
      expect(find.text('Mga Emergency Hotline'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Login', () {
    testWidgets('sends the same sign-in request from the glass card',
        (tester) async {
      await pumpPage(tester, const LoginPage());

      for (final id in ['email_input', 'password_input', 'login_button', 'nav_to_signup']) {
        expect(automationId(id), findsOneWidget, reason: id);
      }

      await tester.enterText(find.byType(TextFormField).at(0), 'juan@gmail.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'Moonwalk#01');
      await tester.ensureVisible(find.text('CONTINUE'));
      await tester.tap(find.text('CONTINUE'));
      await tester.pump();

      final login = sentEvents().single as LoginRequested;
      expect(login.email, 'juan@gmail.com');
      expect(login.password, 'Moonwalk#01');
    });

    testWidgets('Google button still starts Google sign-in', (tester) async {
      await pumpPage(tester, const LoginPage());

      await tester.ensureVisible(find.text('Continue with Google'));
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();

      expect(sentEvents().single, isA<GoogleSignInRequested>());
    });

    testWidgets('lays out in Filipino at night without errors', (tester) async {
      AppColors.isDarkMode = true;
      await pumpPage(tester, const LoginPage(), locale: filipino);

      expect(find.text('MAG-SIGN IN'), findsOneWidget);
      expect(find.text('Magpatuloy gamit ang Google'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Sign Up', () {
    testWidgets('registers a resident only after the terms are accepted',
        (tester) async {
      await pumpPage(tester, const SignUpPage());

      for (final id in [
        'name_input',
        'email_input',
        'password_input',
        'confirm_password_input',
        'terms_checkbox',
        'register_button',
      ]) {
        expect(automationId(id), findsOneWidget, reason: id);
      }

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Juan Dela Cruz');
      await tester.enterText(fields.at(1), 'juan@gmail.com');
      await tester.enterText(fields.at(2), 'Moonwalk#01');
      await tester.enterText(fields.at(3), 'Moonwalk#01');

      await tester.ensureVisible(find.text('CREATE ACCOUNT').last);
      await tester.tap(find.text('CREATE ACCOUNT').last);
      await tester.pump();
      verifyNever(() => authBloc.add(any()));

      await tester.ensureVisible(find.text('I accept the Terms and Conditions'));
      await tester.tap(find.text('I accept the Terms and Conditions'));
      await tester.pump();
      await tester.ensureVisible(find.text('CREATE ACCOUNT').last);
      await tester.tap(find.text('CREATE ACCOUNT').last);
      await tester.pump();

      final register = sentEvents().single as RegisterRequested;
      expect(register.email, 'juan@gmail.com');
      expect(register.password, 'Moonwalk#01');
      expect(register.fullName, 'Juan Dela Cruz');
      expect(register.role, 'resident');
    });

    testWidgets('lays out in Filipino at night without errors', (tester) async {
      AppColors.isDarkMode = true;
      await pumpPage(tester, const SignUpPage(), locale: filipino);

      expect(find.text('Tinatanggap ko ang Mga Tuntunin at Kundisyon'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Email verification', () {
    testWidgets('shows the address and counts down to resend', (tester) async {
      await pumpPage(
        tester,
        const EmailVerificationPage(email: 'juan@gmail.com'),
      );

      expect(find.text('juan@gmail.com'), findsOneWidget);
      expect(find.text('Verification Pending'), findsOneWidget);
      expect(find.text('Resend Link in 58s'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Resend Link in 57s'), findsOneWidget);
    });

    testWidgets('long-pressing the badge still opens the demo bypass',
        (tester) async {
      await pumpPage(
        tester,
        const EmailVerificationPage(email: 'juan@gmail.com'),
      );

      await tester.longPress(find.text('Republic of the Philippines • Brgy. Moonwalk'));
      await settle(tester);
      expect(find.text('Defense Demo Bypass'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect(find.text('Defense Demo Bypass'), findsNothing);
    });

    testWidgets('Sign Out still logs out and returns to Welcome',
        (tester) async {
      await pumpPage(
        tester,
        const EmailVerificationPage(email: 'juan@gmail.com'),
      );

      await tester.ensureVisible(find.text('Wrong email address? Sign Out'));
      await tester.tap(find.text('Wrong email address? Sign Out'));
      await settle(tester);

      expect(sentEvents().single, isA<LogoutRequested>());
      expect(find.text('welcome route'), findsOneWidget);
    });

    testWidgets('lays out in Filipino at night without errors', (tester) async {
      AppColors.isDarkMode = true;
      await pumpPage(
        tester,
        const EmailVerificationPage(email: 'juan@gmail.com'),
        locale: filipino,
      );

      expect(find.text('I-verify ang Iyong Email'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Sign-in alerts', () {
    Future<BuildContext> pumpHost(WidgetTester tester) async {
      late BuildContext context;
      await pumpPage(
        tester,
        Scaffold(body: Builder(builder: (c) {
          context = c;
          return const SizedBox.expand();
        })),
      );
      return context;
    }

    testWidgets('invalid credentials shows its message and closes',
        (tester) async {
      final context = await pumpHost(tester);

      AuthModals.showInvalidCredentials(context);
      await settle(tester);
      expect(find.text('Invalid Credentials'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await settle(tester);
      expect(find.text('Invalid Credentials'), findsNothing);
    });

    testWidgets('admin account notice shows its message and closes',
        (tester) async {
      final context = await pumpHost(tester);

      AuthModals.showAdminAccountBlocked(context);
      await settle(tester);
      expect(find.text('Admin Account Detected'), findsOneWidget);

      await tester.tap(find.text('Understood'));
      await settle(tester);
      expect(find.text('Admin Account Detected'), findsNothing);
    });

    testWidgets('account lock shows the countdown', (tester) async {
      final context = await pumpHost(tester);

      AuthModals.showAccountLocked(
        context,
        DateTime.now().add(const Duration(minutes: 15)),
      );
      await settle(tester);

      expect(find.text('Account Temporarily Locked'), findsOneWidget);
      expect(find.text('remaining'), findsOneWidget);
      expect(find.textContaining(RegExp(r'^1[45]:\d\d$')), findsOneWidget);
    });
  });
}
