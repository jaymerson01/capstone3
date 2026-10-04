import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:community_safety_app/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:community_safety_app/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:community_safety_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:community_safety_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:community_safety_app/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:community_safety_app/features/auth/domain/usecases/update_user_profile_usecase.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/services/fcm_service.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailUseCase signInWithEmailUseCase;
  final SignUpWithEmailUseCase signUpWithEmailUseCase;
  final SignInWithGoogleUseCase? signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateUserProfileUseCase? updateUserProfileUseCase;

  AuthBloc({
    required this.signInWithEmailUseCase,
    required this.signUpWithEmailUseCase,
    this.signInWithGoogleUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    this.updateUserProfileUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithEmailUseCase(event.email, event.password);
    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (user) async {
        await Hive.box('auth').put('isLoggedIn', true);
        await Hive.box('auth').put('userRole', user.role);
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (signInWithGoogleUseCase == null) return;
    emit(AuthLoading());
    final result = await signInWithGoogleUseCase!();
    await result.fold(
      (failure) async {
        if (failure.message.toLowerCase().contains('canceled') ||
            failure.message.toLowerCase().contains('cancelled')) {
          emit(Unauthenticated());
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) async {
        await Hive.box('auth').put('isLoggedIn', true);
        await Hive.box('auth').put('userRole', user.role);
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUpWithEmailUseCase(
      event.email,
      event.password,
      fullName: event.fullName,
      role: event.role,
    );
    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (user) async {
        await Hive.box('auth').put('isLoggedIn', true);
        await Hive.box('auth').put('userRole', user.role);
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) {
        if (user != null) {
          Hive.box('auth').put('isLoggedIn', true);
          Hive.box('auth').put('userRole', user.role);
          emit(Authenticated(user));
        } else {
          Hive.box('auth').put('isLoggedIn', false);
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      try {
        final currentUserId = (state as Authenticated).user.id;
        await sl<FCMService>().removeUserToken(currentUserId);
      } catch (_) {}
    }
    emit(AuthLoading());
    final result = await signOutUseCase();
    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (_) async {
        await Hive.box('auth').put('isLoggedIn', false);
        await Hive.box('auth').delete('userRole');
        emit(Unauthenticated());
      },
    );
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (updateUserProfileUseCase == null) return;
    // Optimistic update: keep user authenticated with updated details immediately (prevents demo flash)
    emit(Authenticated(event.user));
    final result = await updateUserProfileUseCase!(event.user);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (updatedUser) => emit(Authenticated(updatedUser)),
    );
  }
}
