import 'dart:async';

import '../entities/incident_entity.dart';

abstract class IncidentRepository {
  Stream<List<IncidentEntity>> streamActiveIncidents();
  Future<void> submitIncidentReport(IncidentEntity incident);
}
