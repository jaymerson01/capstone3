import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/verification/presentation/verification_watcher.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

const _resident = UserEntity(id: 'r1', email: 'ana@gmail.com');

void main() {
  setUpAll(() => registerFallbackValue(const LogoutRequested()));

  testWidgets('unlocks the app when an admin approves the ID', (tester) async {
    final authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const Authenticated(_resident));
    final verified = StreamController<bool>();
    addTearDown(verified.close);

    await tester.pumpWidget(BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: VerificationWatcher(user: _resident, verified: verified.stream, child: const SizedBox()),
    ));

    verified.add(false); // Still unverified: nothing to do.
    await tester.pump();
    verifyNever(() => authBloc.add(any()));

    verified.add(true);
    await tester.pump();
    final event = verify(() => authBloc.add(captureAny())).captured.single as AuthUserChanged;
    expect(event.user.id, 'r1');
    expect(event.user.isVerified, isTrue);
  });
}
