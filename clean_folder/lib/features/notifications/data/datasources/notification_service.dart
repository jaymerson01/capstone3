import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final CollectionReference _notificationsRef =
      FirebaseFirestore.instance.collection('notifications');

  StreamSubscription? _foregroundListenerSub;
  String? _foregroundUserId;
  final Set<String> _seenNotificationIds = {};

  /// Real-time foreground listener: triggers system heads-up notifications
  /// whenever a new unread notification document appears in Firestore.
  void startForegroundNotificationListener({
    required String userId,
    required void Function(String title, String body, String? incidentId)
        onNotificationReceived,
  }) {
    if (_foregroundUserId == userId && _foregroundListenerSub != null) return;
    _foregroundUserId = userId;
    _foregroundListenerSub?.cancel();
    _seenNotificationIds.clear();

    bool isInitialSnapshot = true;

    _foregroundListenerSub = _notificationsRef
        .where('recipientId', whereIn: [userId, 'all_residents', 'broadcast'])
        .snapshots()
        .listen((snapshot) {
      if (isInitialSnapshot) {
        // Pre-populate existing notification IDs on initial sync so we don't spam past history
        for (final doc in snapshot.docs) {
          _seenNotificationIds.add(doc.id);
        }
        isInitialSnapshot = false;
        debugPrint(
            "🔔 [NotificationService] Foreground listener initialized for user $userId with ${_seenNotificationIds.length} existing notifications.");
        return;
      }

      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final doc = change.doc;
          if (_seenNotificationIds.contains(doc.id)) continue;
          _seenNotificationIds.add(doc.id);

          final notif = NotificationModel.fromFirestore(doc);
          debugPrint(
              "🔔 [NotificationService] New notification received: ${notif.title} - ${notif.message}");

          if (!notif.isRead) {
            onNotificationReceived(notif.title, notif.message, notif.incidentId);
          }
        }
      }
    }, onError: (error) {
      debugPrint("🔔 [NotificationService] Error in foreground listener: $error");
    });
  }


  /// Stop the foreground notification listener
  void stopForegroundNotificationListener() {
    _foregroundUserId = null;
    _foregroundListenerSub?.cancel();
    _foregroundListenerSub = null;
  }

  /// Stream notifications for a resident (specific to user or sent to all_residents)
  Stream<List<NotificationModel>> streamResidentNotifications(String userId) {
    if (userId.isEmpty) {
      return const Stream.empty();
    }

    return _notificationsRef
        .where('recipientId', whereIn: [userId, 'all_residents', 'broadcast'])
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();

          // Sort descending by creation date
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Stream notifications for dispatchers / admins
  Stream<List<NotificationModel>> streamAdminNotifications() {
    return _notificationsRef
        .where('recipientId', isEqualTo: 'admin')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();

          // Sort descending by creation date
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Send a new notification to a specific user, all residents, or admin
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String message,
    required String type,
    String? incidentId,
  }) async {
    try {
      debugPrint("🔔 [NotificationService] Dispatching notification to '$recipientId' [$type]: '$title'");
      await _notificationsRef.add({
        'recipientId': recipientId,
        'title': title,
        'message': message,
        'type': type,
        'incidentId': incidentId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint("🔔 [NotificationService] Notification document written successfully to Firestore.");
    } catch (e) {
      debugPrint("🔔 [NotificationService] Error creating notification: $e");
    }
  }


  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({'isRead': true});
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  /// Mark all unread notifications for a resident as read
  Future<void> markAllResidentAsRead(String userId) async {
    try {
      final snapshot = await _notificationsRef
          .where('recipientId', whereIn: [userId, 'all_residents', 'broadcast'])
          .where('isRead', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Error marking all resident notifications as read: $e");
    }
  }

  /// Mark all unread notifications for admin as read
  Future<void> markAllAdminAsRead() async {
    try {
      final snapshot = await _notificationsRef
          .where('recipientId', isEqualTo: 'admin')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Error marking all admin notifications as read: $e");
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).delete();
    } catch (e) {
      debugPrint("Error deleting notification: $e");
    }
  }
}
