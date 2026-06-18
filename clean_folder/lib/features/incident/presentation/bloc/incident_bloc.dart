import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/incident_repository.dart';
import 'incident_event.dart';
import 'incident_state.dart';

class IncidentBloc extends Bloc<IncidentEvent, IncidentState> {
  final IncidentRepository repository;

  IncidentBloc({required this.repository}) : super(IncidentInitial()) {
    on<SubmitIncidentRequested>(_onSubmitIncidentRequested);
    on<FetchIncidentsRequested>(_onFetchIncidentsRequested);
  }

  Future<void> _onSubmitIncidentRequested(
    SubmitIncidentRequested event,
    Emitter<IncidentState> emit,
  ) async {
    emit(IncidentSubmitLoading());
    final result = await repository.submitIncident(event.incident);
    result.fold(
      (failure) => emit(IncidentSubmitFailure(failure.message)),
      (_) => emit(IncidentSubmitSuccess()),
    );
  }

  Future<void> _onFetchIncidentsRequested(
    FetchIncidentsRequested event,
    Emitter<IncidentState> emit,
  ) async {
    emit(IncidentFetchLoading());
    final result = await repository.getIncidents();
    result.fold(
      (failure) => emit(IncidentFetchFailure(failure.message)),
      (incidents) => emit(IncidentFetchSuccess(incidents)),
    );
  }
}
