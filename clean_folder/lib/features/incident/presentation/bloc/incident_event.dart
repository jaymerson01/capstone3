import '../../domain/entities/incident_entity.dart';

abstract class IncidentEvent {
  const IncidentEvent();
}

class StreamActiveIncidentsRequested extends IncidentEvent {
  const StreamActiveIncidentsRequested();
}

class StreamUserIncidentsRequested extends IncidentEvent {
  final String userId;

  const StreamUserIncidentsRequested(this.userId);
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

class UpvoteIncidentRequested extends IncidentEvent {
  final String incidentId;
  final String userId;

  const UpvoteIncidentRequested(this.incidentId, this.userId);
}

class StreamAllIncidentsRequested extends IncidentEvent {
  const StreamAllIncidentsRequested();
}

class UpdateIncidentStatusRequested extends IncidentEvent {
  final String incidentId;
  final String status;
  final String? dispatcherNotes;
  final String? estimatedResponseTime;

  const UpdateIncidentStatusRequested(
    this.incidentId,
    this.status, {
    this.dispatcherNotes,
    this.estimatedResponseTime,
  });
}

class ArchiveIncidentRequested extends IncidentEvent {
  final String incidentId;

  const ArchiveIncidentRequested(this.incidentId);
}
