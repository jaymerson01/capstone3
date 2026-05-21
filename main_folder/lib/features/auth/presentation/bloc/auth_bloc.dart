import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';

// Events
abstract class AuthEvent {}
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignInRequested(this.email, this.password);
}
class AuthSignOutRequested extends AuthEvent {}

// States
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String role;
  AuthAuthenticated(this.role);
}
class AuthUnauthenticated extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository})
      : super(AuthInitial()) {
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        emit(AuthAuthenticated(user.role));
      } else {
        emit(AuthFailure("Authentication failed."));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // Helper getter to keep references transparent
  AuthRepository get _authRepository => authRepository;
}
