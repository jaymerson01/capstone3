import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/incident_model.dart';

abstract class IncidentRemoteDataSource {
  Future<void> submitIncident(IncidentModel incident);
  Future<List<IncidentModel>> getIncidents();
  Future<void> incrementAffectedCount(String incidentId, String userId);
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

  Future<String> _evaluateUrgency(String description) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        return "MEDIUM";
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system("You are an emergency response triage assistant. Analyze the following incident description and classify its urgency based on immediate threat to life, safety, or property. Respond with EXACTLY one word from these options: LOW, MEDIUM, HIGH. Do not include formatting, punctuation, or extra text."),
      );

      final content = [Content.text("Description: $description")];
      final response = await model.generateContent(content).timeout(const Duration(seconds: 5));

      final result = response.text?.trim().toUpperCase() ?? "MEDIUM";
      
      if (result == "LOW" || result == "MEDIUM" || result == "HIGH") {
        return result;
      }
      return "MEDIUM";
    } catch (e) {
      return "MEDIUM";
    }
  }

  @override
  Future<void> submitIncident(IncidentModel incident) async {
    final urgency = await _evaluateUrgency(incident.description);
    
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
        urgencyStatus: urgency,
        timestamp: incident.timestamp,
        affectedCount: incident.affectedCount,
        affectedUserIds: incident.affectedUserIds,
      );
      await docRef.set(updatedIncident.toMap());
    } else {
      final updatedIncident = IncidentModel(
        id: incident.id,
        title: incident.title,
        description: incident.description,
        latitude: incident.latitude,
        longitude: incident.longitude,
        photoUrl: incident.photoUrl,
        status: incident.status,
        urgencyStatus: urgency,
        timestamp: incident.timestamp,
        affectedCount: incident.affectedCount,
        affectedUserIds: incident.affectedUserIds,
      );
      await firestore.collection('incidents').doc(incident.id).set(updatedIncident.toMap());
    }
  }

  @override
  Future<void> incrementAffectedCount(String incidentId, String userId) async {
    await firestore.collection('incidents').doc(incidentId).update({
      'affectedCount': FieldValue.increment(1),
      'affectedUserIds': FieldValue.arrayUnion([userId]),
    });
  }
}
