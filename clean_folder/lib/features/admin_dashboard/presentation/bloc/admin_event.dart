abstract class AdminEvent {
  const AdminEvent();
}

class AdminLoginRequested extends AdminEvent {
  final String email;
  final String password;
  const AdminLoginRequested(this.email, this.password);
}

class AdminLogoutRequested extends AdminEvent {
  const AdminLogoutRequested();
}
