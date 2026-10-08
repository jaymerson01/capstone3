import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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
      
      final pendingKeys = <dynamic>[];
      final pendingIncidents = <IncidentModel>[];
      
      for (final key in localBox.keys) {
        final incident = localBox.get(key);
        if (incident != null && !incident.isSynced) {
          pendingKeys.add(key);
          pendingIncidents.add(incident);
        }
      }

      for (int i = 0; i < pendingIncidents.length; i++) {
        final incident = pendingIncidents[i];
        try {
          await _firestore.collection('incidents').doc(incident.id).set(incident.toFirestore()).timeout(const Duration(seconds: 15));
          
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

          // Mark as synced
          final updatedIncident = incident.copyWith(isSynced: true);
          
          await localBox.put(pendingKeys[i], updatedIncident);
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
