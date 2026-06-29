import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/incident_entity.dart';
import '../../domain/repositories/incident_repository.dart';
import '../models/incident_model.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final FirebaseFirestore firestore;
  final Box<IncidentModel> localBox;

  IncidentRepositoryImpl({
    required this.firestore,
    required this.localBox,
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
}
