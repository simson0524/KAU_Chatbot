import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:FE/db/chat_dao.dart'; // SQLite 사용
import 'package:intl/intl.dart'; // 시간 포맷
import 'package:FE/chatting_page.dart';
import 'package:FE/main.dart'; // navigatorKey import

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static final ChatDao _chatDao = ChatDao(); // ChatDao 초기화

  static Future<void> initialize() async {
    print("[Notifications] 초기화 시작");


      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('app_icon'),
        iOS: DarwinInitializationSettings(),
      );

      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (
            NotificationResponse response) async {
          print("[Notifications] 알림 클릭: ${response.payload}");
        },
      );

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("[Notifications] 알림 클릭 후 앱 열림: ${message.data}");

        if (message.data.containsKey('chatMessage')) {
          // 알림 클릭 시 ChattingPage로 이동
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => const ChattingPage(),
            ),
          );
        }
      });


      // 포그라운드 메시지 처리
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print("[Notifications] 포그라운드 알림 수신: ${message.notification}");
        print("[Notifications] 메시지 데이터: ${message.data}");

        // 기존 알림 처리
        if (message.notification != null) {
          await showNotification(
            message.notification!.title ?? '알림',
            message.notification!.body ?? '내용 없음',
          );
        }

        // 데이터 알림 처리
        if (message.data.isNotEmpty) {
          await handleDataNotification(message.data);
        }
      });

    // 백그라운드 메시지 처리
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> showNotification(String title, String body) async {
    try {
      print("[Notifications] 알림 표시: 제목=$title, 내용=$body");
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

  static Future<void> handleDataNotification(Map<String, dynamic> data) async {
    print("[Notifications] 데이터 알림 처리 시작");

    if (data.containsKey('chatMessage')) {
      final String messageText = data['chatMessage']; // 메시지 가져오기
      print("[Notifications] 알림 메시지: $messageText");

      // 현재 시간 포맷 설정
      final DateTime now = DateTime.now();
      final String fullTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // 고정된 캐릭터와 isMine 값
      const String fixedCharacter = 'maha';
      const bool isMine = false;
      const String sender = "bot";

      // 새로운 chatId 생성
      final int chatId = await _chatDao.getNewChatId();

      // SQLite에 메시지 저장
      await _chatDao.insertMessage(
        messageText,
        sender,
        fullTimestamp,
        chatId,
        fixedCharacter,
      );

      print("[Notifications] 메시지가 SQLite에 저장되었습니다: $messageText, chatId: $chatId, timestamp: $fullTimestamp");
    } else {
      print("[Notifications] 데이터 알림에 'chatMessage' 필드가 없습니다.");
    }
  }
}

// 백그라운드 메시지 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("[Notifications] 백그라운드 알림 수신: ${message.notification}");
  print("[Notifications] 백그라운드 데이터: ${message.data}");

  if (message.data.isNotEmpty) {
    await NotificationService.handleDataNotification(message.data);
  }
}
