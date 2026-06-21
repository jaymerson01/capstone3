import 'package:dartz/dartz.dart';
import 'package:community_safety_app/core/error/failures.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/domain/repositories/incident_repository.dart';
import '../datasources/incident_remote_data_source.dart';
import '../models/incident_model.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentRemoteDataSource remoteDataSource;

  IncidentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<IncidentEntity>>> getIncidents() async {
    try {
      final models = await remoteDataSource.getIncidents();
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitIncident(IncidentEntity incident) async {
    try {
      final model = IncidentModel(
        id: incident.id,
        title: incident.title,
        description: incident.description,
        latitude: incident.latitude,
        longitude: incident.longitude,
        photoUrl: incident.photoUrl,
        status: incident.status,
        urgencyStatus: incident.urgencyStatus,
        timestamp: incident.timestamp,
        affectedCount: incident.affectedCount,
        affectedUserIds: incident.affectedUserIds,
      );
      await remoteDataSource.submitIncident(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementAffectedCount(String incidentId, String userId) async {
    try {
      await remoteDataSource.incrementAffectedCount(incidentId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
