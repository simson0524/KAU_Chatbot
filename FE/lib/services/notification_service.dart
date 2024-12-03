import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize(BuildContext context) async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        // Handle notification tap
        if (payload != null) {
          print('Notification payload: $payload');
          Navigator.pushNamed(context, '/notificationPage'); // 페이지 이동 예시
        }
      },
    );

    // Configure Firebase Messaging for foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground notification received: ${message.data}');
      if (message.notification != null) {
        showNotification(
          message.notification!.title ?? '알림',
          message.notification!.body ?? '',
        );
      }
    });

    // Configure background and terminated state notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened from background: ${message.data}');
      Navigator.pushNamed(context, '/notificationPage'); // 페이지 이동 예시
    });
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'This is the default channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }
}
