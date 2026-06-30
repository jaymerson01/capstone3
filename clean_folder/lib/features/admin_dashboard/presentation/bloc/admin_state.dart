abstract class AdminState {
  const AdminState();
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminAuthenticated extends AdminState {
  const AdminAuthenticated();
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
}
