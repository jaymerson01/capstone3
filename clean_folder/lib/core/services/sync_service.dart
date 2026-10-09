import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

import '../../features/incident/data/models/incident_model.dart';
import '../../features/notifications/data/datasources/notification_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  Timer? _syncTimer;
  bool _isSyncing = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  void startSyncTimer() {
    _syncTimer?.cancel();
    // Check every 30 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _syncPendingIncidents();
    });
  }

  void stopSyncTimer() {
    _syncTimer?.cancel();
  }

  Future<void> _syncPendingIncidents() async {
    if (_isSyncing) return;
    
    // Check network
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) return;
    } catch (_) {
      return; // Offline
    }

    _isSyncing = true;
    try {
      if (!Hive.isBoxOpen('incidents')) return;
      final localBox = Hive.box<IncidentModel>('incidents');
      
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Every report in this box was saved because the upload failed.
      // (isSynced is not persisted by Hive, so it can't be used as the flag.)
      final pendingKeys = <dynamic>[];
      final pendingIncidents = <IncidentModel>[];

      for (final key in localBox.keys) {
        final incident = localBox.get(key);
        if (incident != null && incident.reporterId == uid) {
          pendingKeys.add(key);
          pendingIncidents.add(incident);
        }
      }

      for (int i = 0; i < pendingIncidents.length; i++) {
        final incident = pendingIncidents[i];
        try {
          final docRef = _firestore.collection('incidents').doc(incident.id);

          // Firestore may already have it (its own offline queue can deliver
          // the write too). Never overwrite a report the admin has updated.
          final existing = await docRef
              .get(const GetOptions(source: Source.server))
              .timeout(const Duration(seconds: 15));
          if (existing.exists) {
            await localBox.delete(pendingKeys[i]);
            continue;
          }

          final batch = _firestore.batch();
          batch.set(docRef, incident.toFirestore());
          batch.set(
            docRef
                .collection(IncidentModel.confidentialCollection)
                .doc(IncidentModel.confidentialDocId),
            incident.toConfidentialFirestore(),
          );
          await batch.commit().timeout(const Duration(seconds: 15));
          
          // Send notification
          final notifTitle = incident.isReportingOnBehalf
              ? '🚨 On Behalf: ${incident.category}'
              : 'New Incident: ${incident.category}';
          final notifMessage = incident.isReportingOnBehalf
              ? 'Reported for ${incident.victimName ?? "affected person"} (${incident.areaSector ?? "Moonwalk"}): ${incident.description.isNotEmpty ? incident.description : "Emergency report"}'
              : '${incident.description.isNotEmpty ? incident.description : "New report filed"} (${incident.areaSector ?? "Moonwalk"}).';

          await _notificationService.sendNotification(
            recipientId: 'admin',
            title: notifTitle,
            message: notifMessage,
            type: 'new_report',
            incidentId: incident.id,
          );

          // Uploaded: the live Firestore copy takes over from here.
          await localBox.delete(pendingKeys[i]);
          debugPrint('Synced incident ${incident.id}');
        } catch (e) {
          debugPrint('Failed to sync incident ${incident.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('SyncService error: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
