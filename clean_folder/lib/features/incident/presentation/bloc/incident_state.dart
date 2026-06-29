import '../../domain/entities/incident_entity.dart';

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
