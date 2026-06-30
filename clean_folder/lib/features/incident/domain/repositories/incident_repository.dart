import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:community_safety_app/core/error/failures.dart';
import '../../data/models/triage_response_model.dart';

import '../entities/incident_entity.dart';

abstract class IncidentRepository {
  Stream<List<IncidentEntity>> streamActiveIncidents();
  Future<void> submitIncidentReport(IncidentEntity incident);
  Future<Either<Failure, TriageResponseModel>> triageIncidentDescription(String description);
}
