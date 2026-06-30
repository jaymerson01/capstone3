import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(const AdminInitial()) {
    on<AdminLoginRequested>(_onAdminLoginRequested);
    on<AdminLogoutRequested>(_onAdminLogoutRequested);
  }

  void _onAdminLoginRequested(AdminLoginRequested event, Emitter<AdminState> emit) {
    // TODO: Wire to Admin Use Case
    emit(const AdminLoading());
    emit(const AdminAuthenticated());
  }

  void _onAdminLogoutRequested(AdminLogoutRequested event, Emitter<AdminState> emit) {
    // TODO: Wire to Admin Use Case
    emit(const AdminInitial());
  }
}
