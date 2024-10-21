import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatApi {
  // 사용자 메시지를 서버에 저장하는 API 호출 함수
  static Future<http.Response> sendMessage(
      String conversationId, String message) async {
    final url = Uri.parse(
        'http://localhost:3000/chatbot/conversation/$conversationId/message');

    try {
      // 서버로 메시지를 POST 요청으로 보냄. 메시지 데이터는 JSON으로 변환하여 전송.
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      return response;
    } catch (error) {
      print('메시지 전송 중 오류 발생: $error');
      throw Exception('메시지 전송 실패');
    }
  }

  // 서버로부터 메시지 히스토리를 불러오는 API 호출 함수
  static Future<List<dynamic>> getMessageHistory(String conversationId) async {
    final url = Uri.parse(
        'http://localhost:3000/chatbot/conversation/$conversationId/history');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('메시지 히스토리 가져오기 실패');
      }
    } catch (error) {
      print('메시지 히스토리 가져오기 중 오류 발생: $error');
      throw Exception('메시지 히스토리 가져오기 실패');
    }
  }
}
