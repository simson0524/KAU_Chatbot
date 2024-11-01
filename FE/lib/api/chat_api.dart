import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatApi {
  // Sends a question to the chatbot and receives the response
  static Future<Map<String, dynamic>> sendQuestion(
      String token, String question, String character) async {
    final url = Uri.parse('http://10.0.2.2:3000/chatbot/conversation/ask');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Token added to Authorization header
        },
        body: json.encode({
          'question': question,
          'chat_character':
              character, // Include character parameter (default: 마하)
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return {
          'answer': responseBody['answer'],
          'tag': responseBody['tag'], // Include tag data if necessary
        };
      } else {
        throw Exception('Failed to send question');
      }
    } catch (error) {
      print('Error sending question: $error');
      throw Exception('Error sending question');
    }
  }
}
