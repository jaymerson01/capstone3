import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:community_safety_app/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:community_safety_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:community_safety_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailUseCase signInWithEmailUseCase;
  final SignUpWithEmailUseCase signUpWithEmailUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.signInWithEmailUseCase,
    required this.signUpWithEmailUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // ignore: avoid_print
    print('🚀 [AUTH BLOC] -> LoginRequested event intercepted successfully!');
    emit(AuthLoading());
    final result = await signInWithEmailUseCase(event.email, event.password);
    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (user) async {
        await Hive.box('auth').put('isLoggedIn', true);
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUpWithEmailUseCase(event.email, event.password);
    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (user) async {
        await Hive.box('auth').put('isLoggedIn', true);
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = Hive.box('auth').get('isLoggedIn', defaultValue: false);
    if (isLoggedIn) {
      emit(AuthLoading());
      final result = await getCurrentUserUseCase();
      result.fold((failure) => emit(AuthInitial()), (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(
            const Authenticated(
              UserEntity(id: 'mock_uid_123', email: 'mocked@resq.com'),
            ),
          );
        }
      });
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signOutUseCase();
    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (_) async {
        await Hive.box('auth').put('isLoggedIn', false);
        emit(AuthInitial());
      },
    );
  }
}
