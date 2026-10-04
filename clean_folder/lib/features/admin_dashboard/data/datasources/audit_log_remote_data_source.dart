import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../models/audit_log_model.dart';

abstract class AuditLogRemoteDataSource {
  Stream<List<AuditLogEntity>> streamAuditLogs();
  Future<void> recordLog({
    required String actionType,
    required String details,
    String? targetId,
    String? adminName,
    String? adminEmail,
  });
}

class AuditLogRemoteDataSourceImpl implements AuditLogRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AuditLogRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  @override
  Stream<List<AuditLogEntity>> streamAuditLogs() {
    return firestore
        .collection('audit_logs')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AuditLogModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> recordLog({
    required String actionType,
    required String details,
    String? targetId,
    String? adminName,
    String? adminEmail,
  }) async {
    try {
      final currentUser = auth.currentUser;
      final resolvedName = adminName ?? currentUser?.displayName ?? 'Admin Officer';
      final resolvedEmail = adminEmail ?? currentUser?.email ?? 'admin@resq.gov';

      final log = AuditLogModel(
        id: '',
        timestamp: DateTime.now(),
        adminName: resolvedName,
        adminEmail: resolvedEmail,
        actionType: actionType,
        details: details,
        targetId: targetId,
      );

      await firestore.collection('audit_logs').add(log.toFirestore());
    } catch (_) {
      // Non-blocking for UI resilience
    }
  }
}
