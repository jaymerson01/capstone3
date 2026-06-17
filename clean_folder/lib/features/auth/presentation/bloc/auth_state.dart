import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}
