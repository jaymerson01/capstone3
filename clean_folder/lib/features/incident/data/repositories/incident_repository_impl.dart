import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:dartz/dartz.dart';
import 'package:community_safety_app/core/error/failures.dart';

import '../../domain/entities/incident_entity.dart';
import '../../domain/repositories/incident_repository.dart';
import '../models/incident_model.dart';
import '../models/triage_response_model.dart';
import '../datasources/incident_ai_remote_data_source.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final FirebaseFirestore firestore;
  final Box<IncidentModel> localBox;
  final IncidentAiRemoteDataSource aiRemoteDataSource;

  IncidentRepositoryImpl({
    required this.firestore,
    required this.localBox,
    required this.aiRemoteDataSource,
  });

  @override
  Stream<List<IncidentEntity>> streamActiveIncidents() {
    return firestore
        .collection('incidents')
        .where('status', isNotEqualTo: 'resolved')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IncidentModel.fromFirestore(doc))
          .toList(); // Implicitly casts List<IncidentModel> to List<IncidentEntity> since IncidentModel extends IncidentEntity
    });
  }

  @override
  Future<void> submitIncidentReport(IncidentEntity incident) async {
    // Map Domain Entity to Data Model
    final incidentModel = IncidentModel(
      id: incident.id,
      reporterId: incident.reporterId,
      description: incident.description,
      category: incident.category,
      photoUrl: incident.photoUrl,
      status: incident.status,
      timestamp: incident.timestamp,
      latitude: incident.latitude,
      longitude: incident.longitude,
      resolvedAddress: incident.resolvedAddress,
      upvoteCount: incident.upvoteCount,
      validatedUserIds: incident.validatedUserIds,
    );

    try {
      // Attempt to inject the incident report directly into the Firestore collection
      await firestore
          .collection('incidents')
          .doc(incidentModel.id)
          .set(incidentModel.toFirestore())
          .timeout(const Duration(seconds: 15)); // Timeout to quickly fallback during emergency
    } on SocketException catch (_) {
      await localBox.put(incidentModel.id, incidentModel);
    } on TimeoutException catch (_) {
      await localBox.put(incidentModel.id, incidentModel);
    } on FirebaseException catch (_) {
      await localBox.put(incidentModel.id, incidentModel);
    } catch (_) {
      // Intercept any other exception payload to ensure offline resiliency
      await localBox.put(incidentModel.id, incidentModel);
    }
  }

  @override
  Future<Either<Failure, TriageResponseModel>> triageIncidentDescription(String description) async {
    try {
      // Check for active network connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        try {
          final triageResponse = await aiRemoteDataSource.analyzeIncidentNarrative(description);
          return Right(triageResponse);
        } on ServerException catch (e) {
          return Left(ServerFailure(e.message));
        } on FormatException catch (e) {
          return Left(ServerFailure(e.message));
        }
      } else {
        return const Left(ServerFailure('No active internet connection'));
      }
    } on SocketException catch (_) {
      return const Left(ServerFailure('No active internet connection'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
