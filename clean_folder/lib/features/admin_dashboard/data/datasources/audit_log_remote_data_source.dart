import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../models/audit_log_model.dart';

/// The signed-in admin's name and email for the audit trail: from their
/// login first, then their profile in `users` (which also holds the name).
/// Never a made-up address.
Future<({String name, String email})> resolveActingAdmin({
  FirebaseAuth? auth,
  FirebaseFirestore? firestore,
}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  // On the web the login is restored a moment after start-up.
  final user = authInstance.currentUser ??
      await authInstance
          .authStateChanges()
          .first
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
  if (user == null) return (name: 'Unknown admin', email: 'not signed in');

  var email = user.email ?? '';
  if (email.isEmpty) {
    email = user.providerData
        .map((info) => info.email ?? '')
        .firstWhere((e) => e.isNotEmpty, orElse: () => '');
  }
  var name = user.displayName ?? '';
  try {
    final profile = await (firestore ?? FirebaseFirestore.instance)
        .collection('users')
        .doc(user.uid)
        .get()
        .timeout(const Duration(seconds: 4));
    final data = profile.data();
    if (data != null) {
      if (email.isEmpty) email = data['email'] as String? ?? '';
      final profileName = (data['displayName'] as String?) ?? (data['fullName'] as String?);
      if (profileName != null && profileName.trim().isNotEmpty) name = profileName.trim();
    }
  } catch (_) {
    // Offline: keep what the login has.
  }
  if (name.trim().isEmpty) name = email.isNotEmpty ? email.split('@').first : 'Admin';
  if (email.isEmpty) email = 'uid ${user.uid}';
  return (name: name, email: email);
}

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
      final hasName = (adminName ?? '').trim().isNotEmpty;
      final hasEmail = (adminEmail ?? '').trim().isNotEmpty;
      final admin = hasName && hasEmail ? null : await resolveActingAdmin(auth: auth, firestore: firestore);
      final resolvedName = hasName ? adminName! : admin!.name;
      final resolvedEmail = hasEmail ? adminEmail! : admin!.email;

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
