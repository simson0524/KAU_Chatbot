import 'package:socket_io_client/socket_io_client.dart' as IO;

class NotificationService {
  late IO.Socket _socket;

  void initialize(
    String serverUrl,
    String studentId,
    Function(Map<String, dynamic>) onNotification,
  ) {
    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket.onConnect((_) {
      print('[DEBUG] Connected to socket: ${_socket.id}');
      _socket.emit('join', studentId); // 학번으로 특정 룸에 가입
    });

    _socket.on('receiveNotification', (data) {
      print('[DEBUG] Notification received: $data');
      onNotification(data); // 알림 데이터를 콜백 함수로 전달
    });

    _socket.onDisconnect((_) {
      print('[DEBUG] Disconnected from socket');
    });
  }

  void dispose() {
    _socket.disconnect();
    _socket.dispose();
  }
}
