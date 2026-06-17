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

  const RegisterRequested(this.email, this.password);
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
