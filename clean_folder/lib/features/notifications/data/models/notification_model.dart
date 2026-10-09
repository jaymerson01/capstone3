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

  /// For shared notifications ('all_residents' / 'broadcast'): residents who
  /// have read / dismissed it. Each resident has their own read state.
  final List<String> readBy;
  final List<String> hiddenFor;

  static const List<String> sharedRecipients = ['all_residents', 'broadcast'];

  bool get isShared => sharedRecipients.contains(recipientId);

  const NotificationModel({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.type,
    this.incidentId,
    required this.isRead,
    required this.createdAt,
    this.readBy = const [],
    this.hiddenFor = const [],
  });

  /// [viewerId] = the resident looking at the list. For shared notifications
  /// "read" means this resident has read it, not anyone.
  factory NotificationModel.fromFirestore(DocumentSnapshot doc, {String? viewerId}) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    DateTime parsedTime = DateTime.now();
    if (data['createdAt'] is Timestamp) {
      parsedTime = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      parsedTime = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
    }

    final recipientId = data['recipientId'] as String? ?? '';
    final readBy = List<String>.from(data['readBy'] as List? ?? const []);
    final hiddenFor = List<String>.from(data['hiddenFor'] as List? ?? const []);
    final bool sharedDoc = sharedRecipients.contains(recipientId);
    final bool readState = (sharedDoc && viewerId != null)
        ? readBy.contains(viewerId)
        : (data['isRead'] as bool? ?? false);

    return NotificationModel(
      id: doc.id,
      recipientId: recipientId,
      title: data['title'] as String? ?? 'Notification',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      incidentId: data['incidentId'] as String?,
      isRead: readState,
      createdAt: parsedTime,
      readBy: readBy,
      hiddenFor: hiddenFor,
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
      readBy: readBy,
      hiddenFor: hiddenFor,
    );
  }
}
