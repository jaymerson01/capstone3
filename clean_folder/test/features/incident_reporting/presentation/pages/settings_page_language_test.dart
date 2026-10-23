import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_safety_app/core/services/locale_controller.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/settings_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LocaleController.localeNotifier.value = LocaleController.english;
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(
      const Authenticated(UserEntity(id: 'resident_1', email: 'resident@example.com')),
    );
  });

  // Same wiring as ResQResidentApp in main_resident.dart.
  Widget buildApp(Widget home) {
    return ListenableBuilder(
      listenable: LocaleController.localeNotifier,
      builder: (context, child) => MaterialApp(
        locale: LocaleController.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BlocProvider<AuthBloc>.value(value: authBloc, child: home),
      ),
    );
  }

  testWidgets('choosing Filipino in App Preferences switches and saves the language',
      (tester) async {
    await tester.pumpWidget(buildApp(const SettingsPage(isRootTab: true)));
    await tester.dragUntilVisible(
      find.text('Language'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('Language'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Filipino'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(LocaleController.locale, LocaleController.filipino);
    expect(find.text('Wika'), findsOneWidget);
    expect(find.text('Filipino'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), 'fil');
  });

  testWidgets('Edit Personal Details no longer has a language dropdown',
      (tester) async {
    await tester.pumpWidget(buildApp(const EditProfilePage()));
    await tester.pump();

    expect(find.text('Language Preference'), findsNothing);
    expect(find.text('App Interface Language'), findsNothing);
  });
}
