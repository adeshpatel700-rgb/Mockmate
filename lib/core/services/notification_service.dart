/// ═══════════════════════════════════════════════════════════════════════════
/// 🔔 NOTIFICATION SERVICE — Firebase + OneSignal Push Notifications
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Handles all push notification logic:
/// - Foreground, background, and terminated state handling
/// - OneSignal for cross-platform push delivery
/// - Local notifications for in-app notification display
///
/// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// ── Background Message Handler ─────────────────────────────────────────────
// MUST be a top-level function (not inside a class) for FCM background handling.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger().i('📩 Background FCM message: ${message.messageId}');
}

// ── Notification Channel (Android 8.0+) ───────────────────────────────────
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'mockmate_high_importance_channel',
  'MockMate Notifications',
  description: 'Interview reminders, streak alerts, achievements and more.',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
  showBadge: true,
);

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _logger = Logger();
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _firebaseMessaging = FirebaseMessaging.instance;

  bool _initialized = false;

  // ── Initialize ─────────────────────────────────────────────────────────
  Future<void> initialize({
    required String oneSignalAppId,
    void Function(Map<String, dynamic> payload)? onNotificationTap,
  }) async {
    if (_initialized) return;

    // 1. Background FCM handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    _logger.i(
      '🔔 Notification permission: ${settings.authorizationStatus}',
    );

    // 3. Set up local notifications
    await _setupLocalNotifications(onNotificationTap: onNotificationTap);

    // 4. Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 5. Foreground notification display (Android)
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 6. Handle FCM foreground messages → show as local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('📨 Foreground FCM: ${message.notification?.title}');
      _showLocalNotificationFromFCM(message);
    });

    // 7. Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i('📲 App opened from notification: ${message.data}');
      onNotificationTap?.call(message.data);
    });

    // 8. Handle notification tap when app was terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _logger.i('🚀 App launched from notification: ${initialMessage.data}');
      onNotificationTap?.call(initialMessage.data);
    }

    // 9. OneSignal setup
    await _setupOneSignal(appId: oneSignalAppId);

    // 10. Log FCM token (for testing)
    final token = await _firebaseMessaging.getToken();
    _logger.i('📱 FCM Token: $token');

    _initialized = true;
    _logger.i('✅ NotificationService initialized');
  }

  // ── OneSignal Setup ─────────────────────────────────────────────────────
  Future<void> _setupOneSignal({required String appId}) async {
    // Set log level (verbose for dev, none for production)
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize(appId);

    // Request permission via OneSignal
    await OneSignal.Notifications.requestPermission(true);

    // Listen for notification will display
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      _logger.i(
        '📣 OneSignal foreground: ${event.notification.title}',
      );
      // Display the notification
      event.notification.display();
    });

    // Listen for notification tap
    OneSignal.Notifications.addClickListener((event) {
      _logger.i(
        '👆 OneSignal tapped: ${event.notification.additionalData}',
      );
    });

    _logger.i('✅ OneSignal initialized with appId: $appId');
  }

  // ── Local Notifications Setup ───────────────────────────────────────────
  Future<void> _setupLocalNotifications({
    void Function(Map<String, dynamic> payload)? onNotificationTap,
  }) async {
    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {},
    );

    final initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final payload =
                jsonDecode(response.payload!) as Map<String, dynamic>;
            onNotificationTap?.call(payload);
          } catch (_) {}
        }
      },
    );
  }

  // ── Show Local Notification ─────────────────────────────────────────────
  Future<void> _showLocalNotificationFromFCM(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  // ── Send Local Notification (manual) ───────────────────────────────────
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload != null ? jsonEncode(payload) : null,
    );
  }

  // ── Subscribe to Topic ──────────────────────────────────────────────────
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    _logger.i('✅ Subscribed to topic: $topic');
  }

  // ── Unsubscribe from Topic ──────────────────────────────────────────────
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    _logger.i('✅ Unsubscribed from topic: $topic');
  }

  // ── Get FCM Token ───────────────────────────────────────────────────────
  Future<String?> getFCMToken() async {
    return _firebaseMessaging.getToken();
  }

  // ── Link OneSignal to User ──────────────────────────────────────────────
  Future<void> loginUser(String userId) async {
    await OneSignal.login(userId);
    _logger.i('✅ OneSignal user linked: $userId');
  }

  // ── Unlink OneSignal User ───────────────────────────────────────────────
  Future<void> logoutUser() async {
    await OneSignal.logout();
    _logger.i('✅ OneSignal user unlinked');
  }
}
