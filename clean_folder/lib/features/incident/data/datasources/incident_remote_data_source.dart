import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_model.dart';

abstract class IncidentRemoteDataSource {
  Future<void> submitIncident(IncidentModel incident);
  Future<List<IncidentModel>> getIncidents();
}

class IncidentRemoteDataSourceImpl implements IncidentRemoteDataSource {
  final FirebaseFirestore firestore;

  IncidentRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<IncidentModel>> getIncidents() async {
    final snapshot = await firestore
        .collection('incidents')
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => IncidentModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> submitIncident(IncidentModel incident) async {
    if (incident.id.isEmpty) {
      final docRef = firestore.collection('incidents').doc();
      final updatedIncident = IncidentModel(
        id: docRef.id,
        title: incident.title,
        description: incident.description,
        latitude: incident.latitude,
        longitude: incident.longitude,
        photoUrl: incident.photoUrl,
        status: incident.status,
        timestamp: incident.timestamp,
      );
      await docRef.set(updatedIncident.toMap());
    } else {
      await firestore.collection('incidents').doc(incident.id).set(incident.toMap());
    }
  }
}
