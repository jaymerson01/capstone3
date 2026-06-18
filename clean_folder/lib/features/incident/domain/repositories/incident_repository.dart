import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/incident_entity.dart';

abstract class IncidentRepository {
  Future<Either<Failure, void>> submitIncident(IncidentEntity incident);
  Future<Either<Failure, List<IncidentEntity>>> getIncidents();
}
