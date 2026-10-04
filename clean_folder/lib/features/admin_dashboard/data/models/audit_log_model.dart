import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/audit_log_entity.dart';

class AuditLogModel extends AuditLogEntity {
  const AuditLogModel({
    required super.id,
    required super.timestamp,
    required super.adminName,
    required super.adminEmail,
    required super.actionType,
    required super.details,
    super.targetId,
  });

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parsedTimestamp = DateTime.now();
    if (data['timestamp'] != null) {
      if (data['timestamp'] is Timestamp) {
        parsedTimestamp = (data['timestamp'] as Timestamp).toDate();
      } else if (data['timestamp'] is String) {
        parsedTimestamp = DateTime.tryParse(data['timestamp']) ?? DateTime.now();
      }
    }

    return AuditLogModel(
      id: doc.id,
      timestamp: parsedTimestamp,
      adminName: data['adminName'] as String? ?? 'Admin',
      adminEmail: data['adminEmail'] as String? ?? 'admin@resq.gov',
      actionType: data['actionType'] as String? ?? 'General Action',
      details: data['details'] as String? ?? '',
      targetId: data['targetId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'adminName': adminName,
      'adminEmail': adminEmail,
      'actionType': actionType,
      'details': details,
      if (targetId != null) 'targetId': targetId,
    };
  }
}
