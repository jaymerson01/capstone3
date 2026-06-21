import '../../domain/entities/incident_entity.dart';

abstract class IncidentEvent {
  const IncidentEvent();
}

class SubmitIncidentRequested extends IncidentEvent {
  final IncidentEntity incident;

  const SubmitIncidentRequested(this.incident);
}

class FetchIncidentsRequested extends IncidentEvent {
  const FetchIncidentsRequested();
}

class IncrementAffectedCountRequested extends IncidentEvent {
  final String incidentId;
  final String userId;

  const IncrementAffectedCountRequested(this.incidentId, this.userId);
}
