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
