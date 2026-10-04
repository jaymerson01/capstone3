import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:community_safety_app/core/error/failures.dart';
import '../../data/models/triage_response_model.dart';

import '../entities/incident_entity.dart';

abstract class IncidentRepository {
  Stream<List<IncidentEntity>> streamActiveIncidents();
  Stream<List<IncidentEntity>> streamUserIncidents(String userId);
  Future<void> submitIncidentReport(IncidentEntity incident);
  Future<Either<Failure, TriageResponseModel>> triageIncidentDescription(String description);
  Future<void> upvoteIncident(String incidentId, String userId);
  Stream<List<IncidentEntity>> streamAllIncidents();
  Future<void> updateIncidentStatus(String id, String status, {String? dispatcherNotes, String? estimatedResponseTime});
  Future<void> archiveIncident(String id);
}
