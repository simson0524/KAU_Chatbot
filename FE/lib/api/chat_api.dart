import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatApi {
  // 대화 시작 API 호출 함수
  static Future<Map<String, dynamic>> startConversation(String userId) async {
    final url = Uri.parse('http://10.0.2.2:3000/chatbot/conversation');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to start conversation');
      }
    } catch (error) {
      print('Error starting conversation: $error');
      throw Exception('Error starting conversation');
    }
  }

  // 질문을 챗봇에게 보내는 API 호출 함수
  static Future<String> sendQuestion(
      String conversationId, String question) async {
    final url = Uri.parse(
        'http://10.0.2.2:3000/chatbot/conversation/$conversationId/ask');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'conversation_id': conversationId,
          'question': question,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['response'];
      } else {
        throw Exception('Failed to send question');
      }
    } catch (error) {
      print('Error sending question: $error');
      throw Exception('Error sending question');
    }
  }
}
