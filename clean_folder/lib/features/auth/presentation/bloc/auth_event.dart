import '../../domain/entities/user_entity.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String? fullName;
  final String role;

  const RegisterRequested(
    this.email,
    this.password, {
    this.fullName,
    this.role = 'resident',
  });
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class UpdateProfileRequested extends AuthEvent {
  final UserEntity user;

  const UpdateProfileRequested(this.user);
}
