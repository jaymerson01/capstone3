import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/incident_repository.dart';
import 'incident_event.dart';
import 'incident_state.dart';

class IncidentBloc extends Bloc<IncidentEvent, IncidentState> {
  final IncidentRepository repository;
  StreamSubscription? _incidentStreamSubscription;

  IncidentBloc({required this.repository}) : super(IncidentInitial()) {
    on<StreamActiveIncidentsRequested>(_onStreamActiveIncidentsRequested);
    on<IncidentsUpdated>(_onIncidentsUpdated);
    on<IncidentsError>(_onIncidentsError);
    on<SubmitIncidentReportRequested>(_onSubmitIncidentReportRequested);
  }

  void _onStreamActiveIncidentsRequested(
    StreamActiveIncidentsRequested event,
    Emitter<IncidentState> emit,
  ) {
    emit(IncidentLoading());
    _incidentStreamSubscription?.cancel();
    
    // Connect to the Domain Repository Stream
    _incidentStreamSubscription = repository.streamActiveIncidents().listen(
      (incidents) {
        add(IncidentsUpdated(incidents));
      },
      onError: (error) {
        add(IncidentsError(error.toString()));
      },
    );
  }

  void _onIncidentsUpdated(
    IncidentsUpdated event,
    Emitter<IncidentState> emit,
  ) {
    emit(IncidentLoaded(event.incidents));
  }

  void _onIncidentsError(
    IncidentsError event,
    Emitter<IncidentState> emit,
  ) {
    emit(IncidentError(event.message));
  }

  Future<void> _onSubmitIncidentReportRequested(
    SubmitIncidentReportRequested event,
    Emitter<IncidentState> emit,
  ) async {
    emit(IncidentSubmitLoading());
    try {
      await repository.submitIncidentReport(event.incident);
      emit(IncidentSubmitSuccess());
      // Upon successful submission, the Firestore Snapshot listener will automatically
      // detect the new document, trigger the stream, and map the UI into IncidentLoaded.
    } catch (e) {
      emit(IncidentSubmitFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _incidentStreamSubscription?.cancel();
    return super.close();
  }
}
