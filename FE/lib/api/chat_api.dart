import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatApi {
  // Sends a question to the chatbot and receives the response
  static Future<Map<String, dynamic>> sendQuestion(
      String token, String question, String character) async {
    final url = Uri.parse('http://3.37.153.10:3000/chat/ask');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'question': question,
          'chat_character': character,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['answer'] != null && responseBody['tag'] != null) {
          return {
            'answer': responseBody['answer'],
            'tag': responseBody['tag'],
          };
        } else {
          print('Unexpected response format: $responseBody');
          throw Exception('Invalid response format');
        }
      } else {
        print(
            'Error response: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to send question');
      }
    } catch (error) {
      print('Error sending question: $error');
      throw Exception('Error sending question');
    }
  }
}
