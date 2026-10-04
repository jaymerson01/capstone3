import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String recipientId; // User UID, 'all_residents', or 'admin'
  final String title;
  final String message;
  final String type; // 'status_change', 'upvote', 'siren', 'new_report', 'general'
  final String? incidentId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.type,
    this.incidentId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    DateTime parsedTime = DateTime.now();
    if (data['createdAt'] is Timestamp) {
      parsedTime = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      parsedTime = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
    }

    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] as String? ?? '',
      title: data['title'] as String? ?? 'Notification',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      incidentId: data['incidentId'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: parsedTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipientId': recipientId,
      'title': title,
      'message': message,
      'type': type,
      'incidentId': incidentId,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? title,
    String? message,
    String? type,
    String? incidentId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      incidentId: incidentId ?? this.incidentId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
