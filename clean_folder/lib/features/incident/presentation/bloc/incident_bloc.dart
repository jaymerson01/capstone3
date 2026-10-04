import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/incident_entity.dart';
import '../../domain/repositories/incident_repository.dart';
import '../../domain/usecases/triage_incident_usecase.dart';
import '../../data/models/incident_model.dart';
import 'incident_event.dart';
import 'incident_state.dart';

class IncidentBloc extends Bloc<IncidentEvent, IncidentState> {
  final IncidentRepository repository;
  final TriageIncidentUseCase triageIncidentUseCase;
  StreamSubscription? _incidentStreamSubscription;

  IncidentBloc({
    required this.repository,
    required this.triageIncidentUseCase,
  }) : super(IncidentInitial()) {
    on<StreamActiveIncidentsRequested>(_onStreamActiveIncidentsRequested);
    on<StreamUserIncidentsRequested>(_onStreamUserIncidentsRequested);
    on<IncidentsUpdated>(_onIncidentsUpdated);
    on<IncidentsError>(_onIncidentsError);
    on<SubmitIncidentReportRequested>(_onSubmitIncidentReportRequested);
    on<AnalyzeIncidentNarrativeEvent>(_onAnalyzeIncidentNarrativeEvent);
    on<UpvoteIncidentRequested>(_onUpvoteIncidentRequested);
    on<StreamAllIncidentsRequested>(_onStreamAllIncidentsRequested);
    on<UpdateIncidentStatusRequested>(_onUpdateIncidentStatusRequested);
    on<ArchiveIncidentRequested>(_onArchiveIncidentRequested);
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

  void _onStreamUserIncidentsRequested(
    StreamUserIncidentsRequested event,
    Emitter<IncidentState> emit,
  ) {
    emit(IncidentLoading());
    _incidentStreamSubscription?.cancel();
    
    _incidentStreamSubscription = repository.streamUserIncidents(event.userId).listen(
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

  Future<void> _onAnalyzeIncidentNarrativeEvent(
    AnalyzeIncidentNarrativeEvent event,
    Emitter<IncidentState> emit,
  ) async {
    emit(IncidentTriageLoading());
    final result = await triageIncidentUseCase.call(event.description);
    
    result.fold(
      (failure) => emit(IncidentTriageError(failure.message)),
      (triageResult) => emit(IncidentTriageLoaded(triageResult)),
    );
  }

  Future<void> _onUpvoteIncidentRequested(
    UpvoteIncidentRequested event,
    Emitter<IncidentState> emit,
  ) async {
    try {
      await repository.upvoteIncident(event.incidentId, event.userId);
    } catch (e) {
      emit(IncidentError("Failed to upvote incident: $e"));
    }
  }

  void _onStreamAllIncidentsRequested(
    StreamAllIncidentsRequested event,
    Emitter<IncidentState> emit,
  ) {
    emit(IncidentLoading());
    _incidentStreamSubscription?.cancel();

    _incidentStreamSubscription = repository.streamAllIncidents().listen(
      (incidents) {
        add(IncidentsUpdated(incidents));
      },
      onError: (error) {
        add(IncidentsError(error.toString()));
      },
    );
  }

  Future<void> _onUpdateIncidentStatusRequested(
    UpdateIncidentStatusRequested event,
    Emitter<IncidentState> emit,
  ) async {
    final normalized = IncidentStatusExtension.normalize(event.status);
    if (state is IncidentLoaded) {
      final currentList = (state as IncidentLoaded).incidents;
      final updatedList = currentList.map((inc) {
        if (inc.id == event.incidentId) {
          return IncidentEntity(
            id: inc.id,
            reporterId: inc.reporterId,
            description: inc.description,
            category: inc.category,
            photoUrl: inc.photoUrl,
            videoUrl: inc.videoUrl,
            status: normalized,
            urgencyStatus: inc.urgencyStatus,
            timestamp: inc.timestamp,
            latitude: inc.latitude,
            longitude: inc.longitude,
            resolvedAddress: inc.resolvedAddress,
            upvoteCount: inc.upvoteCount,
            validatedUserIds: inc.validatedUserIds,
            areaSector: inc.areaSector,
            isAnonymous: inc.isAnonymous,
            dispatcherNotes: event.dispatcherNotes ?? inc.dispatcherNotes,
            reporterName: inc.reporterName,
            reporterEmail: inc.reporterEmail,
            isSynced: true,
            isReportingOnBehalf: inc.isReportingOnBehalf,
            victimName: inc.victimName,
            victimPhone: inc.victimPhone,
            estimatedResponseTime: event.estimatedResponseTime ?? inc.estimatedResponseTime,
          );
        }
        return inc;
      }).toList();
      emit(IncidentLoaded(updatedList));
    }

    try {
      await repository.updateIncidentStatus(
        event.incidentId,
        event.status,
        dispatcherNotes: event.dispatcherNotes,
        estimatedResponseTime: event.estimatedResponseTime,
      );
    } catch (e) {
      emit(IncidentError("Failed to update status: $e"));
    }
  }

  Future<void> _onArchiveIncidentRequested(
    ArchiveIncidentRequested event,
    Emitter<IncidentState> emit,
  ) async {
    if (state is IncidentLoaded) {
      final currentList = (state as IncidentLoaded).incidents;
      final updatedList = currentList.map((inc) {
        if (inc.id == event.incidentId) {
          return IncidentEntity(
            id: inc.id,
            reporterId: inc.reporterId,
            description: inc.description,
            category: inc.category,
            photoUrl: inc.photoUrl,
            videoUrl: inc.videoUrl,
            status: 'archived',
            urgencyStatus: inc.urgencyStatus,
            timestamp: inc.timestamp,
            latitude: inc.latitude,
            longitude: inc.longitude,
            resolvedAddress: inc.resolvedAddress,
            upvoteCount: inc.upvoteCount,
            validatedUserIds: inc.validatedUserIds,
            areaSector: inc.areaSector,
            isAnonymous: inc.isAnonymous,
            dispatcherNotes: inc.dispatcherNotes,
            reporterName: inc.reporterName,
            reporterEmail: inc.reporterEmail,
            isSynced: true,
          );
        }
        return inc;
      }).toList();
      emit(IncidentLoaded(updatedList));
    }

    try {
      await repository.archiveIncident(event.incidentId);
    } catch (e) {
      emit(IncidentError("Failed to archive incident: $e"));
    }
  }

  @override
  Future<void> close() {
    _incidentStreamSubscription?.cancel();
    return super.close();
  }
}
