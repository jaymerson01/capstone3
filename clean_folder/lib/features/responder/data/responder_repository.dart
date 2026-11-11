import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:community_safety_app/core/utils/departments.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/notifications/data/datasources/notification_service.dart';

/// Responder progress on a report, after Accept.
abstract final class ResponderStatus {
  static const onTheWay = 'on_the_way';
  static const onScene = 'on_scene';
}

/// What the responder portal reads and writes. firestore.rules lets a
/// responder change only the reports assigned to them (or accept an
/// unassigned one of their department), and only these fields.
class ResponderRepository {
  ResponderRepository({FirebaseFirestore? firestore, NotificationService? notifications})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _notifications = notifications ?? NotificationService();

  final FirebaseFirestore _firestore;
  final NotificationService _notifications;

  CollectionReference<Map<String, dynamic>> get _incidents => _firestore.collection('incidents');

  /// The department's open reports plus everything assigned to [uid] (so
  /// their resolved ones stay listed), newest first.
  Stream<List<IncidentModel>> streamReports(Department department, String uid) {
    return _incidents
        .where('status', whereIn: const ['pending', 'in_progress', 'resolved'])
        .snapshots()
        .map((snapshot) => reportsFor(
              snapshot.docs.map(IncidentModel.fromFirestore).toList(),
              department,
              uid,
            ));
  }

  /// Which reports a responder of [department] sees.
  @visibleForTesting
  static List<IncidentModel> reportsFor(List<IncidentModel> all, Department department, String uid) {
    final mine = all.where((i) {
      if (i.assignedResponderId == uid) return true;
      if (i.isSolved) return false;
      return i.departments.contains(department);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return mine;
  }

  /// One report, live; null once it's deleted.
  Stream<IncidentModel?> watchReport(String incidentId) {
    return _incidents.doc(incidentId).snapshots().map((doc) => doc.exists ? IncidentModel.fromFirestore(doc) : null);
  }

  /// The reporter's name, email and phone. Readable only once the report is
  /// assigned to this responder.
  Future<Map<String, dynamic>?> contactFor(String incidentId) async {
    final doc = await _incidents
        .doc(incidentId)
        .collection(IncidentModel.confidentialCollection)
        .doc(IncidentModel.confidentialDocId)
        .get();
    return doc.data();
  }

  /// Takes an unassigned report. Fails if someone else took it first.
  Future<void> accept(IncidentEntity report, {required String uid, required String name}) async {
    final ref = _incidents.doc(report.id);
    await _firestore.runTransaction((tx) async {
      final current = await tx.get(ref);
      final taken = current.data()?['assignedResponderId'];
      if (taken != null && taken != uid) throw StateError('already-assigned');
      tx.update(ref, {
        'assignedResponderId': uid,
        'assignedResponderName': name,
        'assignedAt': FieldValue.serverTimestamp(),
      });
    });
    await _notifyAdmins(report, '$name accepted ${report.ticketNumber}');
  }

  /// On the way or on the scene: the report goes In progress if it wasn't.
  Future<void> setProgress(IncidentEntity report, String responderStatus, {required String name}) async {
    await _incidents.doc(report.id).update({
      'responderStatus': responderStatus,
      'responderStatusAt': FieldValue.serverTimestamp(),
      if (!report.isInProgress) ...{
        'status': 'in_progress',
        'inProgressAt': FieldValue.serverTimestamp(),
        'respondedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final onTheWay = responderStatus == ResponderStatus.onTheWay;
    // The live position is only for the trip there.
    if (!onTheWay) await stopSharing(report.id);
    await _notifyReporter(
      report,
      onTheWay
          ? 'Papunta na ang responder · A responder is on the way'
          : 'Nasa lugar na ang responder · The responder is on the scene',
      name,
    );
    await _notifyAdmins(report, '$name is ${onTheWay ? 'on the way to' : 'on the scene of'} ${report.ticketNumber}');
  }

  /// Marks the report resolved, with what was done.
  Future<void> resolve(IncidentEntity report, {required String name, String? notes}) async {
    await _incidents.doc(report.id).update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
      'respondedAt': FieldValue.serverTimestamp(),
      if (notes != null && notes.trim().isNotEmpty) 'responderNotes': notes.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await stopSharing(report.id);
    await _notifyReporter(report, 'Nalutas na ang ulat mo · Your report is resolved', name);
    await _notifyAdmins(report, '$name resolved ${report.ticketNumber}');
  }

  Future<void> saveNotes(String incidentId, String notes) =>
      _incidents.doc(incidentId).update({'responderNotes': notes.trim()});

  Future<void> savePhoto(String incidentId, String url) =>
      _incidents.doc(incidentId).update({'responderPhotoUrl': url});

  /// Where a report's live responder position is kept, apart from the report
  /// so only the reporter, admins and the assigned responder can read it.
  DocumentReference<Map<String, dynamic>> _tracking(String incidentId) =>
      _incidents.doc(incidentId).collection('tracking').doc('responder');

  /// The responder's position while on the way.
  Future<void> shareLocation(String incidentId, double latitude, double longitude, {required String name}) {
    return _tracking(incidentId).set({
      'lat': latitude,
      'lng': longitude,
      'name': name,
      'at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> stopSharing(String incidentId) async {
    try {
      await _tracking(incidentId).delete();
    } catch (e) {
      debugPrint('[Responder] Clearing the shared location failed: $e');
    }
  }

  Future<void> _notifyReporter(IncidentEntity report, String title, String name) async {
    if (report.reporterId.isEmpty) return;
    await _notifications.sendNotification(
      recipientId: report.reporterId,
      title: title,
      message: 'Ticket ${report.ticketNumber} · $name',
      type: 'status_change',
      incidentId: report.id,
    );
  }

  Future<void> _notifyAdmins(IncidentEntity report, String message) {
    return _notifications.sendNotification(
      recipientId: 'admin',
      title: 'Responder update',
      message: message,
      type: 'responder_update',
      incidentId: report.id,
    );
  }
}
