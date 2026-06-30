import '../../domain/entities/incident_entity.dart';
import '../../data/models/triage_response_model.dart';

abstract class IncidentState {
  const IncidentState();
}

class IncidentInitial extends IncidentState {}

class IncidentLoading extends IncidentState {}

class IncidentLoaded extends IncidentState {
  final List<IncidentEntity> incidents;

  const IncidentLoaded(this.incidents);
}

class IncidentError extends IncidentState {
  final String message;

  const IncidentError(this.message);
}

// Submission specific states
class IncidentSubmitLoading extends IncidentState {}

class IncidentSubmitSuccess extends IncidentState {}

class IncidentSubmitFailure extends IncidentState {
  final String message;

  const IncidentSubmitFailure(this.message);
}

// AI Triage specific states
class IncidentTriageLoading extends IncidentState {}

class IncidentTriageLoaded extends IncidentState {
  final TriageResponseModel triageResult;

  const IncidentTriageLoaded(this.triageResult);
}

class IncidentTriageError extends IncidentState {
  final String message;

  const IncidentTriageError(this.message);
}
