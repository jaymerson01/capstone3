import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:community_safety_app/firebase_options.dart';

/// Top-level background message entrypoint required by Flutter Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("🔔 [FCM Background] Received message: ${message.messageId}");
    debugPrint("🔔 [FCM Background] Title: ${message.notification?.title ?? message.data['title']}");
    debugPrint("🔔 [FCM Background] Body: ${message.notification?.body ?? message.data['message']}");
  } catch (e) {
    debugPrint("🔔 [FCM Background] Error handling background message: $e");
  }
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'resq_emergency_alerts_v3';
  static const String channelName = 'ResQ Emergency Alerts & Siren Broadcasts';
  static const String channelDescription =
      'Critical real-time notifications for disaster alarms, dispatcher status updates, and community safety corroborations.';

  static const AndroidNotificationChannel _emergencyChannel =
      AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('resq_alert'),
    enableVibration: true,
  );

  bool _isInitialized = false;
  Function(String? incidentId)? _onNotificationTapCallback;

  /// Initialize FCM, local notification channels, and notification listeners
  Future<void> initialize({Function(String? incidentId)? onNotificationTap}) async {
    if (_isInitialized) return;
    _onNotificationTapCallback = onNotificationTap;

    // 1. Request User Notification Permission (especially Android 13+ & iOS)
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );

    debugPrint('🔔 [FCM] Authorization Status: ${settings.authorizationStatus}');

    // 2. Configure Android & iOS Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        debugPrint("🔔 [LocalNotification] Tapped with payload: $payload");
        if (_onNotificationTapCallback != null) {
          _onNotificationTapCallback!(payload);
        }
      },
    );

    // 3. Create High-Importance Notification Channel for Android
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Request Android 13+ (API 33+) POST_NOTIFICATIONS permission
      await androidImplementation.requestNotificationsPermission();

      // Clean up previous cached channels so new sound settings take effect
      try {
        await androidImplementation.deleteNotificationChannel('resq_emergency_alerts');
        await androidImplementation.deleteNotificationChannel('resq_emergency_alerts_v2');
      } catch (_) {}

      await androidImplementation.createNotificationChannel(_emergencyChannel);
    }

    // 4. Foreground Notification Presentation Options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Handle Foreground Messages (App is active and on screen)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🔔 [FCM Foreground] Received: ${message.notification?.title}");
      // Pushes from our Cloud Functions mirror Firestore events that the open
      // app already shows (siren modal, notification bell + local alert), so
      // showing them again here would double-alert the resident.
      if (message.data['origin'] == 'resq_functions') return;
      _displayForegroundNotification(message);
    });

    // 6. Handle notification click when app is in background but memory resident
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("🔔 [FCM OpenedApp] User clicked notification: ${message.data}");
      final incidentId = message.data['incidentId'] as String?;
      if (_onNotificationTapCallback != null) {
        _onNotificationTapCallback!(incidentId);
      }
    });

    // 7. Check if app was opened directly from a terminated state via notification click
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("🔔 [FCM InitialMessage] App launched from killed state via notification");
      final incidentId = initialMessage.data['incidentId'] as String?;
      if (_onNotificationTapCallback != null) {
        _onNotificationTapCallback!(incidentId);
      }
    }

    // 8. Auto-subscribe all citizen devices to broadcast siren alerts topic
    try {
      await _messaging.subscribeToTopic('resq_emergency_broadcasts');
      debugPrint("🔔 [FCM] Subscribed to topic: 'resq_emergency_broadcasts'");
    } catch (e) {
      debugPrint("🔔 [FCM] Failed to subscribe to topic: $e");
    }

    _isInitialized = true;
  }

  /// Explicitly requests notification permissions at runtime (especially when UI is interactive)
  Future<bool?> requestNotificationPermissions() async {
    try {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        debugPrint("🔔 [FCMService] Android POST_NOTIFICATIONS granted: $granted");
        return granted;
      }
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint("🔔 [FCMService] Error requesting notification permissions: $e");
      return false;
    }
  }

  /// Display a heads-up floating notification when message arrives in foreground
  Future<void> _displayForegroundNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'] ?? 'ResQ Alert';
    final body = message.notification?.body ?? message.data['message'] ?? '';
    final incidentId = message.data['incidentId'] as String?;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('resq_alert'),
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        sound: 'resq_alert.wav',
      ),
    );

    final notifId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    try {
      await _localNotifications.show(
        notifId,
        title,
        body,
        platformDetails,
        payload: incidentId,
      );
    } catch (e) {
      debugPrint("🔔 [FCM Foreground] Custom sound failed: $e, displaying with standard notification");
      const fallbackAndroidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );
      const fallbackPlatformDetails = NotificationDetails(
        android: fallbackAndroidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      );
      await _localNotifications.show(
        notifId,
        title,
        body,
        fallbackPlatformDetails,
        payload: incidentId,
      );
    }
  }

  /// Manually trigger a local notification banner (e.g. from in-app events or tests)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? incidentId,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('resq_alert'),
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        sound: 'resq_alert.wav',
      ),
    );

    final notifId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    try {
      await _localNotifications.show(
        notifId,
        title,
        body,
        platformDetails,
        payload: incidentId,
      );
    } catch (e) {
      debugPrint("🔔 [LocalNotification] Custom sound failed: $e, falling back to standard notification");
      const fallbackAndroidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );
      const fallbackPlatformDetails = NotificationDetails(
        android: fallbackAndroidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      );
      await _localNotifications.show(
        notifId,
        title,
        body,
        fallbackPlatformDetails,
        payload: incidentId,
      );
    }
  }

  /// Retrieve the current FCM Device Registration Token
  Future<String?> getDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint("════════════════════════════════════════════════════════════");
      debugPrint("🔥 [FCM DEVICE TOKEN]: $token");
      debugPrint("════════════════════════════════════════════════════════════");
      return token;
    } catch (e) {
      debugPrint("🔔 [FCM] Failed to retrieve device token: $e");
      return null;
    }
  }

  /// Sync device token to Firestore users/{uid}/fcmTokens
  Future<void> syncUserToken(String userId) async {
    if (userId.isEmpty) return;
    try {
      final token = await getDeviceToken();
      if (token == null || token.isEmpty) return;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastFcmUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint("🔔 [FCM] Synced token for user $userId to Firestore");
    } catch (e) {
      debugPrint("🔔 [FCM] Error syncing token to Firestore: $e");
    }
  }

  /// Unregister device token on logout
  Future<void> removeUserToken(String userId) async {
    if (userId.isEmpty) return;
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
        debugPrint("🔔 [FCM] Removed token for user $userId on logout");
      }
    } catch (e) {
      debugPrint("🔔 [FCM] Error removing token: $e");
    }
  }
}
