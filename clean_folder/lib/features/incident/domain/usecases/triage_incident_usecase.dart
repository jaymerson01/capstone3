import 'package:dartz/dartz.dart';
import 'package:community_safety_app/core/error/failures.dart';
import '../repositories/incident_repository.dart';
import '../../data/models/triage_response_model.dart';

class TriageIncidentUseCase {
  final IncidentRepository repository;

  TriageIncidentUseCase(this.repository);

  Future<Either<Failure, TriageResponseModel>> call(String description) {
    return repository.triageIncidentDescription(description);
  }
}
