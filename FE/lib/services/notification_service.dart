import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    print("[Notifications] 초기화 시작");
    try {
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('app_icon'),
        iOS: DarwinInitializationSettings(),
      );

      // 알림 초기화
      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          print("[Notifications] 알림 클릭: ${response.payload}");
        },
      );
      print("[Notifications] 초기화 완료");
    } catch (e) {
      print("[Notifications] 초기화 중 오류 발생: $e");
    }

    // 포그라운드 메시지 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("[Notifications] 포그라운드 알림 수신: ${message.notification}");
      print("[Notifications] 메시지 데이터: ${message.data}");

      if (message.notification != null) {
        // 기존 알림 처리
        showNotification(
          message.notification!.title ?? '알림',
          message.notification!.body ?? '내용 없음',
        );
      }

      if (message.data.isNotEmpty) {
        // 데이터 알림 처리
        handleDataNotification(message.data);
      }
    });

    // 사용자가 알림을 클릭해 앱을 연 경우
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("[Notifications] 알림 클릭 후 앱 열림: ${message.data}");

      if (message.data.isNotEmpty) {
        handleDataNotification(message.data);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> showNotification(String title, String body) async {
    try {
      print("[Notifications] 알림 표시: 제목=$title, 내용=$body");
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        channelDescription: 'This is the default channel',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

      await _localNotificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
      );
      print("[Notifications] 알림 표시 완료");
    } catch (e) {
      print("[Notifications] 알림 표시 중 오류 발생: $e");
    }
  }

  static Future<String?> getToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        print("[Notifications] FCM 토큰 생성 성공: $fcmToken");
      } else {
        print("[Notifications] FCM 토큰 생성 실패: null");
      }
      return fcmToken;
    } catch (e) {
      print("[Notifications] FCM 토큰 가져오기 중 오류 발생: $e");
      return null;
    }
  }

  // 데이터 알림 처리
  static void handleDataNotification(Map<String, dynamic> data) {
    print("[Notifications] 데이터 알림 처리");
    if (data.containsKey('interests')) {
      final interests = data['interests'];
      print("[Notifications] 다음 공지들을 확인해보세요: $interests");
    } else {
      print("[Notifications] ");
    }
  }
}

// 백그라운드 메시지 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("[Notifications] 백그라운드 알림 수신: ${message.notification}");
  print("[Notifications] 백그라운드 데이터: ${message.data}");

  if (message.notification != null) {
    print("[Notifications] 제목=${message.notification!.title}");
    print("[Notifications] 내용=${message.notification!.body}");
  }

  if (message.data.isNotEmpty) {
    NotificationService.handleDataNotification(message.data);
  }
}
