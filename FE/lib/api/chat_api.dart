import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatApi {
  // 사용자 메시지를 서버에 저장하는 API 호출 함수
  static Future<http.Response> sendMessage(
      String conversationId, String message) async {
    final url = Uri.parse(
        'http://your-server.com/chatbot/conversation/$conversationId/message');

    try {
      // 서버로 메시지를 POST 요청으로 보냄. 메시지 데이터는 JSON으로 변환하여 전송.
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'}, // JSON 형식으로 데이터 전송
        body: json
            .encode({'message': message}), // message 데이터를 JSON으로 변환하여 서버로 전송
      );

      // 서버 응답을 반환하여 상태 코드 및 응답 본문을 처리할 수 있도록 함
      return response;
    } catch (error) {
      // 네트워크 오류 발생 시 로그 출력 후 예외 발생
      print('메시지 전송 중 오류 발생: $error');
      throw Exception('메시지 전송 실패');
    }
  }

  // 서버로부터 메시지 히스토리를 불러오는 API 호출 함수
  static Future<List<dynamic>> getMessageHistory(String conversationId) async {
    final url = Uri.parse(
        'http://your-server.com/chatbot/conversation/$conversationId/history');

    try {
      // GET 요청으로 메시지 히스토리를 불러옴
      final response = await http.get(url);

      // 서버 응답이 성공적일 경우 메시지 데이터를 JSON으로 디코드하여 반환
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // 서버 응답이 성공적이지 않을 경우 예외 발생
        throw Exception('메시지 히스토리 가져오기 실패');
      }
    } catch (error) {
      // 네트워크 오류 발생 시 로그 출력 후 예외 발생
      print('메시지 히스토리 가져오기 중 오류 발생: $error');
      throw Exception('메시지 히스토리 가져오기 실패');
    }
  }
}
