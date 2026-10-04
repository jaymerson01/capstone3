class AuditLogEntity {
  final String id;
  final DateTime timestamp;
  final String adminName;
  final String adminEmail;
  final String actionType;
  final String details;
  final String? targetId;

  const AuditLogEntity({
    required this.id,
    required this.timestamp,
    required this.adminName,
    required this.adminEmail,
    required this.actionType,
    required this.details,
    this.targetId,
  });
}
