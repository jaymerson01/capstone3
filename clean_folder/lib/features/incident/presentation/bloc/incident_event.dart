import '../../domain/entities/incident_entity.dart';

abstract class IncidentEvent {
  const IncidentEvent();
}

class StreamActiveIncidentsRequested extends IncidentEvent {
  const StreamActiveIncidentsRequested();
}

class IncidentsUpdated extends IncidentEvent {
  final List<IncidentEntity> incidents;

  const IncidentsUpdated(this.incidents);
}

class IncidentsError extends IncidentEvent {
  final String message;

  const IncidentsError(this.message);
}

class SubmitIncidentReportRequested extends IncidentEvent {
  final IncidentEntity incident;

  const SubmitIncidentReportRequested(this.incident);
}

class AnalyzeIncidentNarrativeEvent extends IncidentEvent {
  final String description;

  const AnalyzeIncidentNarrativeEvent(this.description);
}
