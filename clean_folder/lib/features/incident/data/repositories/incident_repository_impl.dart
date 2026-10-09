import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:dartz/dartz.dart';
import 'package:community_safety_app/core/error/failures.dart';
import 'package:community_safety_app/core/error/exceptions.dart';

import '../../domain/entities/incident_entity.dart';
import '../../domain/repositories/incident_repository.dart';
import '../models/incident_model.dart';
import '../models/triage_response_model.dart';
import '../datasources/incident_ai_remote_data_source.dart';
import 'package:community_safety_app/core/utils/incident_triage_helper.dart';
import 'package:community_safety_app/features/notifications/data/datasources/notification_service.dart';
import 'package:community_safety_app/features/admin_dashboard/data/models/audit_log_model.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final FirebaseFirestore firestore;
  final Box<IncidentModel> localBox;
  final IncidentAiRemoteDataSource aiRemoteDataSource;

  IncidentRepositoryImpl({
    required this.firestore,
    required this.localBox,
    required this.aiRemoteDataSource,
  });

  CollectionReference<Map<String, dynamic>> get _incidents =>
      firestore.collection('incidents');

  /// incidents/{id}/confidential/contact — reporter & victim contact details.
  DocumentReference<Map<String, dynamic>> _confidentialRef(String incidentId) =>
      _incidents
          .doc(incidentId)
          .collection(IncidentModel.confidentialCollection)
          .doc(IncidentModel.confidentialDocId);

  /// Contact details the signed-in resident may read: only their own filings.
  Query<Map<String, dynamic>>? _ownConfidentialQuery() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return firestore
        .collectionGroup(IncidentModel.confidentialCollection)
        .where('reporterId', isEqualTo: uid);
  }

  /// Joins the public incident stream with the contact details the current
  /// user is allowed to see. If contact details can't be read, the public
  /// data still flows (names simply stay hidden).
  Stream<List<IncidentEntity>> _withConfidential(
    Stream<QuerySnapshot<Map<String, dynamic>>> publicStream,
    Query<Map<String, dynamic>>? confidentialQuery,
    List<IncidentEntity> Function(
      QuerySnapshot<Map<String, dynamic>> snapshot,
      Map<String, Map<String, dynamic>> contacts,
    ) build,
  ) {
    if (confidentialQuery == null) {
      return publicStream.map((snapshot) => build(snapshot, const {}));
    }

    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? publicSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? contactSub;
    QuerySnapshot<Map<String, dynamic>>? lastPublic;
    Map<String, Map<String, dynamic>> contacts = {};
    late final StreamController<List<IncidentEntity>> controller;

    void emitLatest() {
      final snapshot = lastPublic;
      if (snapshot != null && !controller.isClosed) {
        controller.add(build(snapshot, contacts));
      }
    }

    controller = StreamController<List<IncidentEntity>>.broadcast(
      onListen: () {
        publicSub = publicStream.listen(
          (snapshot) {
            lastPublic = snapshot;
            emitLatest();
          },
          onError: controller.addError,
        );
        contactSub = confidentialQuery.snapshots().listen(
          (snapshot) {
            contacts = {
              for (final doc in snapshot.docs)
                if (doc.reference.parent.parent != null)
                  doc.reference.parent.parent!.id: doc.data(),
            };
            emitLatest();
          },
          onError: (Object error) {
            debugPrint('[IncidentRepository] Contact details unavailable: $error');
          },
        );
      },
      onCancel: () async {
        await publicSub?.cancel();
        await contactSub?.cancel();
      },
    );
    return controller.stream;
  }

  /// One-time clean-up for reports filed before contact details were split
  /// out: moves names/emails/phones from the public doc into the
  /// confidential sub-document. Runs from the admin desk (admins only).
  final Set<String> _migratedIncidentIds = {};

  void _migrateLegacyContactFields(QuerySnapshot<Map<String, dynamic>> snapshot) {
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final legacyKeys =
          IncidentModel.confidentialKeys.where(data.containsKey).toList();
      if (legacyKeys.isEmpty || _migratedIncidentIds.contains(doc.id)) continue;
      _migratedIncidentIds.add(doc.id);

      final batch = firestore.batch();
      batch.set(
        _confidentialRef(doc.id),
        {
          'reporterId': data['reporterId'] ?? data['userId'] ?? '',
          for (final key in legacyKeys) key: data[key],
        },
        SetOptions(merge: true),
      );
      batch.update(doc.reference, {
        for (final key in legacyKeys) key: FieldValue.delete(),
      });
      batch.commit().catchError((Object error) {
        debugPrint('[IncidentRepository] Contact migration skipped for ${doc.id}: $error');
        _migratedIncidentIds.remove(doc.id);
      });
    }
  }

  @override
  Stream<List<IncidentEntity>> streamActiveIncidents() {
    return _withConfidential(
        _incidents.snapshots(includeMetadataChanges: true),
        _ownConfidentialQuery(), (snapshot, contacts) {
      final List<IncidentModel> firestoreIncidents = snapshot.docs
          .map((doc) =>
              IncidentModel.fromFirestore(doc).withConfidential(contacts[doc.id]))
          .where((i) => i.status.toLowerCase() != 'archived')
          .toList();

      final Set<String> existingIds =
          firestoreIncidents.map((i) => i.id).toSet();
      final List<IncidentEntity> localHiveIncidents = localBox.values
          .where((i) =>
              !existingIds.contains(i.id) &&
              i.status.toLowerCase() != 'archived')
          .map((i) => IncidentModel(
                id: i.id,
                reporterId: i.reporterId,
                description: i.description,
                category: i.category,
                photoUrl: i.photoUrl,
                status: i.status,
                urgencyStatus: i.urgencyStatus,
                timestamp: i.timestamp,
                latitude: i.latitude,
                longitude: i.longitude,
                resolvedAddress: i.resolvedAddress,
                upvoteCount: i.upvoteCount,
                validatedUserIds: i.validatedUserIds,
                areaSector: i.areaSector,
                isAnonymous: i.isAnonymous,
                dispatcherNotes: i.dispatcherNotes,
                reporterName: i.reporterName,
                reporterEmail: i.reporterEmail,
                videoUrl: i.videoUrl,
                isSynced: false,
                isReportingOnBehalf: i.isReportingOnBehalf,
                victimName: i.victimName,
                victimPhone: i.victimPhone,
                estimatedResponseTime: i.estimatedResponseTime,
              ))
          .toList();

      final combined = [...firestoreIncidents, ...localHiveIncidents];
      combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return combined;
    });
  }

  @override
  Stream<List<IncidentEntity>> streamUserIncidents(String userId) {
    return _withConfidential(
        _incidents
            .where('reporterId', isEqualTo: userId)
            .snapshots(includeMetadataChanges: true),
        _ownConfidentialQuery(), (snapshot, contacts) {
      final List<IncidentModel> firestoreIncidents = snapshot.docs
          .map((doc) =>
              IncidentModel.fromFirestore(doc).withConfidential(contacts[doc.id]))
          .toList();

      // Retrieve any offline reports saved in Hive not yet registered in Firestore
      final Set<String> existingIds = firestoreIncidents.map((i) => i.id).toSet();
      final List<IncidentEntity> localHiveIncidents = localBox.values
          .where((i) => (i.reporterId == userId || userId == 'resident_local') && !existingIds.contains(i.id))
          .map((i) => IncidentModel(
                id: i.id,
                reporterId: i.reporterId,
                description: i.description,
                category: i.category,
                photoUrl: i.photoUrl,
                status: i.status,
                urgencyStatus: i.urgencyStatus,
                timestamp: i.timestamp,
                latitude: i.latitude,
                longitude: i.longitude,
                resolvedAddress: i.resolvedAddress,
                upvoteCount: i.upvoteCount,
                validatedUserIds: i.validatedUserIds,
                areaSector: i.areaSector,
                isAnonymous: i.isAnonymous,
                dispatcherNotes: i.dispatcherNotes,
                reporterName: i.reporterName,
                reporterEmail: i.reporterEmail,
                videoUrl: i.videoUrl,
                isSynced: false,
                isReportingOnBehalf: i.isReportingOnBehalf,
                victimName: i.victimName,
                victimPhone: i.victimPhone,
                estimatedResponseTime: i.estimatedResponseTime,
              ))
          .toList();

      final combined = [...firestoreIncidents, ...localHiveIncidents];
      combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return combined;
    });
  }

  @override
  Future<void> submitIncidentReport(IncidentEntity incident) async {
    final docRef = incident.id.isEmpty
        ? firestore.collection('incidents').doc()
        : firestore.collection('incidents').doc(incident.id);
    final generatedId = docRef.id;

    final incidentModel = IncidentModel(
      id: generatedId,
      reporterId: incident.reporterId,
      description: incident.description,
      category: incident.category,
      photoUrl: incident.photoUrl,
      videoUrl: incident.videoUrl,
      status: incident.status,
      urgencyStatus: (incident.urgencyStatus != null && incident.urgencyStatus!.isNotEmpty)
          ? incident.urgencyStatus!.toUpperCase()
          : IncidentTriageHelper.getBaselineUrgency(incident.category),
      timestamp: incident.timestamp,
      latitude: incident.latitude,
      longitude: incident.longitude,
      resolvedAddress: incident.resolvedAddress,
      upvoteCount: incident.upvoteCount,
      validatedUserIds: incident.validatedUserIds,
      areaSector: incident.areaSector,
      isAnonymous: incident.isAnonymous,
      dispatcherNotes: incident.dispatcherNotes,
      reporterName: incident.reporterName,
      reporterEmail: incident.reporterEmail,
      isReportingOnBehalf: incident.isReportingOnBehalf,
      victimName: incident.victimName,
      victimPhone: incident.victimPhone,
      estimatedResponseTime: incident.estimatedResponseTime,
    );

    try {
      final batch = firestore.batch();
      batch.set(docRef, incidentModel.toFirestore());
      batch.set(_confidentialRef(generatedId), incidentModel.toConfidentialFirestore());
      await batch.commit().timeout(const Duration(seconds: 15));

      // Notify admin command center of incoming report
      final notifTitle = incident.isReportingOnBehalf
          ? '🚨 On Behalf: ${incident.category}'
          : 'New Incident: ${incident.category}';
      final notifMessage = incident.isReportingOnBehalf
          ? 'Reported for ${incident.victimName ?? "affected person"} (${incident.areaSector ?? "Moonwalk"}): ${incident.description.isNotEmpty ? incident.description : "Emergency report"}'
          : '${incident.description.isNotEmpty ? incident.description : "New report filed"} (${incident.areaSector ?? "Moonwalk"}).';

      await NotificationService().sendNotification(
        recipientId: 'admin',
        title: notifTitle,
        message: notifMessage,
        type: 'new_report',
        incidentId: generatedId,
      );
    } catch (e) {
      await localBox.put(generatedId, incidentModel);
      throw OfflineException('Failed to upload report to server. Saved locally.');
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

  @override
  Future<void> upvoteIncident(String incidentId, String userId) async {
    bool upvoteSaved = false;
    try {
      final docRef = firestore.collection('incidents').doc(incidentId);

      // Security rules only accept exactly +1 with the voter's own uid, once.
      // Urgency escalation is derived from upvoteCount when the report is read.
      await docRef.update({
        'upvoteCount': FieldValue.increment(1),
        'validatedUserIds': FieldValue.arrayUnion([userId]),
      });
      upvoteSaved = true;
    } catch (_) {
      // Local Hive fallback for offline or demo testing
      if (localBox.containsKey(incidentId)) {
        final existing = localBox.get(incidentId);
        if (existing != null) {
          final updatedUserIds = List<String>.from(existing.validatedUserIds);
          if (!updatedUserIds.contains(userId)) {
            updatedUserIds.add(userId);
          }
          final newCount = existing.upvoteCount + 1;
          final newUrgency = IncidentTriageHelper.calculateEffectiveUrgency(
            category: existing.category,
            upvoteCount: newCount,
            currentUrgency: existing.urgencyStatus,
          );

          final updatedModel = IncidentModel(
            id: existing.id,
            reporterId: existing.reporterId,
            description: existing.description,
            category: existing.category,
            photoUrl: existing.photoUrl,
            status: existing.status,
            urgencyStatus: newUrgency,
            timestamp: existing.timestamp,
            latitude: existing.latitude,
            longitude: existing.longitude,
            resolvedAddress: existing.resolvedAddress,
            upvoteCount: newCount,
            validatedUserIds: updatedUserIds,
            areaSector: existing.areaSector,
            isAnonymous: existing.isAnonymous,
            dispatcherNotes: existing.dispatcherNotes,
            reporterName: existing.reporterName,
            reporterEmail: existing.reporterEmail,
            videoUrl: existing.videoUrl,
            isSynced: false,
            isReportingOnBehalf: existing.isReportingOnBehalf,
            victimName: existing.victimName,
            victimPhone: existing.victimPhone,
            estimatedResponseTime: existing.estimatedResponseTime,
          );
          await localBox.put(incidentId, updatedModel);
        }
      }
    }

    // Dispatch notification to original report author
    if (!upvoteSaved) return;
    try {
      final docSnap =
          await firestore.collection('incidents').doc(incidentId).get();
      if (docSnap.exists) {
        final data = docSnap.data();
        final reporterId = data?['reporterId'] as String? ?? '';
        final category = data?['category'] as String? ?? 'incident';
        final sector = data?['areaSector'] as String? ?? 'your area';
        if (reporterId.isNotEmpty && reporterId != userId) {
          await NotificationService().sendNotification(
            recipientId: reporterId,
            title: 'Neighbor Corroborated Report',
            message:
                'A resident verified your $category incident in $sector.',
            type: 'upvote',
            incidentId: incidentId,
          );
        }
      }
    } catch (_) {}
  }

  @override
  Stream<List<IncidentEntity>> streamAllIncidents() {
    // Admin desk: every report plus every contact sub-document.
    return _withConfidential(
        _incidents.snapshots(includeMetadataChanges: true),
        firestore.collectionGroup(IncidentModel.confidentialCollection),
        (snapshot, contacts) {
      _migrateLegacyContactFields(snapshot);
      final List<IncidentModel> firestoreIncidents = snapshot.docs
          .map((doc) =>
              IncidentModel.fromFirestore(doc).withConfidential(contacts[doc.id]))
          .toList();

      final Set<String> existingIds = firestoreIncidents.map((i) => i.id).toSet();
      final List<IncidentEntity> localHiveIncidents = localBox.values
          .where((i) => !existingIds.contains(i.id))
          .map((i) => IncidentModel(
                id: i.id,
                reporterId: i.reporterId,
                description: i.description,
                category: i.category,
                photoUrl: i.photoUrl,
                status: i.status,
                urgencyStatus: i.urgencyStatus,
                timestamp: i.timestamp,
                latitude: i.latitude,
                longitude: i.longitude,
                resolvedAddress: i.resolvedAddress,
                upvoteCount: i.upvoteCount,
                validatedUserIds: i.validatedUserIds,
                areaSector: i.areaSector,
                isAnonymous: i.isAnonymous,
                dispatcherNotes: i.dispatcherNotes,
                reporterName: i.reporterName,
                reporterEmail: i.reporterEmail,
                videoUrl: i.videoUrl,
                isSynced: false,
                isReportingOnBehalf: i.isReportingOnBehalf,
                victimName: i.victimName,
                victimPhone: i.victimPhone,
                estimatedResponseTime: i.estimatedResponseTime,
              ))
          .toList();

      final combined = [...firestoreIncidents, ...localHiveIncidents];
      combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return combined;
    });
  }

  @override
  Future<void> updateIncidentStatus(String id, String status, {String? dispatcherNotes, String? estimatedResponseTime}) async {
    final normalizedStatus = IncidentStatusExtension.normalize(status);
    final Map<String, dynamic> updateData = {
      'status': normalizedStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (normalizedStatus == 'in_progress' || normalizedStatus == 'resolved') {
      updateData['respondedAt'] = FieldValue.serverTimestamp();
    }
    if (dispatcherNotes != null && dispatcherNotes.isNotEmpty) {
      updateData['dispatcherNotes'] = dispatcherNotes;
    }
    if (estimatedResponseTime != null && estimatedResponseTime.isNotEmpty) {
      updateData['estimatedResponseTime'] = estimatedResponseTime;
    }

    try {
      await firestore.collection('incidents').doc(id).update(updateData);
    } catch (_) {
      try {
        await firestore
            .collection('incidents')
            .doc(id)
            .set(updateData, SetOptions(merge: true));
      } catch (_) {}
      // Offline / Local box fallback
      if (localBox.containsKey(id)) {
        final existing = localBox.get(id);
        if (existing != null) {
          final updated = IncidentModel(
            id: existing.id,
            reporterId: existing.reporterId,
            description: existing.description,
            category: existing.category,
            photoUrl: existing.photoUrl,
            videoUrl: existing.videoUrl,
            status: normalizedStatus,
            urgencyStatus: existing.urgencyStatus,
            timestamp: existing.timestamp,
            latitude: existing.latitude,
            longitude: existing.longitude,
            resolvedAddress: existing.resolvedAddress,
            upvoteCount: existing.upvoteCount,
            validatedUserIds: existing.validatedUserIds,
            areaSector: existing.areaSector,
            isAnonymous: existing.isAnonymous,
            dispatcherNotes: dispatcherNotes ?? existing.dispatcherNotes,
            reporterName: existing.reporterName,
            reporterEmail: existing.reporterEmail,
            isSynced: false,
            isReportingOnBehalf: existing.isReportingOnBehalf,
            victimName: existing.victimName,
            victimPhone: existing.victimPhone,
            estimatedResponseTime: estimatedResponseTime ?? existing.estimatedResponseTime,
          );
          await localBox.put(id, updated);
        }
      }
    }

    // Dispatch in-app notification to the original author
    try {
      final docSnap = await firestore.collection('incidents').doc(id).get();
      if (docSnap.exists) {
        final data = docSnap.data();
        final reporterId = (data?['reporterId'] as String?)?.isNotEmpty == true
            ? data!['reporterId'] as String
            : (data?['userId'] as String? ?? '');
        final category = data?['category'] as String? ?? 'Incident';
        if (reporterId.isNotEmpty) {
          final displayStatus =
              normalizedStatus.toUpperCase().replaceAll('_', ' ');
          String msg = 'Your $category report is now $displayStatus.';
          if (estimatedResponseTime != null && estimatedResponseTime.trim().isNotEmpty) {
            msg += ' Estimated arrival: $estimatedResponseTime.';
          }
          if (dispatcherNotes != null && dispatcherNotes.trim().isNotEmpty) {
            msg += ' Note: $dispatcherNotes';
          }
          await NotificationService().sendNotification(
            recipientId: reporterId,
            title: 'Report Status: $displayStatus',
            message: msg,
            type: 'status_change',
            incidentId: id,
          );
        } else {
          debugPrint("🔔 [IncidentRepository] No reporterId found for incident $id to notify.");
        }
      }
    } catch (e) {
      debugPrint("🔔 [IncidentRepository] Error sending status notification: $e");
    }


    // Record immutable audit log
    try {
      final etaSnippet = (estimatedResponseTime != null && estimatedResponseTime.trim().isNotEmpty)
          ? " | ETA: $estimatedResponseTime"
          : "";
      final notesSnippet = (dispatcherNotes != null && dispatcherNotes.trim().isNotEmpty)
          ? " | Remarks: $dispatcherNotes"
          : "";
      final currentUser = FirebaseAuth.instance.currentUser;
      final adminEmail = currentUser?.email ?? 'dispatch@resq.gov';
      final adminName = (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty)
          ? currentUser.displayName!
          : 'Duty Dispatch Officer';

      final log = AuditLogModel(
        id: '',
        timestamp: DateTime.now(),
        adminName: adminName,
        adminEmail: adminEmail,
        actionType: 'Status Update',
        details: 'Updated incident #$id status to "${normalizedStatus.toUpperCase()}"$etaSnippet$notesSnippet',
        targetId: id,
      );
      await firestore.collection('audit_logs').add(log.toFirestore());

    } catch (_) {}
  }

  @override
  Future<void> archiveIncident(String id) async {
    await updateIncidentStatus(id, 'archived');
  }
}
