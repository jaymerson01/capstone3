import '../../domain/entities/incident_entity.dart';

abstract class IncidentState {
  const IncidentState();
}

class IncidentInitial extends IncidentState {}

class IncidentSubmitLoading extends IncidentState {}

class IncidentSubmitSuccess extends IncidentState {}

class IncidentSubmitFailure extends IncidentState {
  final String message;

  const IncidentSubmitFailure(this.message);
}

class IncidentFetchLoading extends IncidentState {}

class IncidentFetchSuccess extends IncidentState {
  final List<IncidentEntity> incidents;

  const IncidentFetchSuccess(this.incidents);
}

class IncidentFetchFailure extends IncidentState {
  final String message;

  const IncidentFetchFailure(this.message);
}
