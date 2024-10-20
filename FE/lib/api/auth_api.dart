import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthApi {
  // 회원가입 API 호출 함수
  static Future<http.Response> register(
      String studentId,
      String email,
      String password,
      String name,
      String major,
      String grade,
      String gender,
      String residence) async {
    final url = Uri.parse('http://localhost:3000/user/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_id': studentId,
          'email': email,
          'password': password,
          'name': name,
          'major': major,
          'grade': grade,
          'gender': gender,
          'residence': residence
        }),
      );

      return response;
    } catch (error) {
      print('Error occurred during registration: $error');
      throw Exception('Registration failed');
    }
  }

  // 로그인 API 호출 함수
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('http://localhost:3000/user/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return {
          'success': true,
          'token': responseBody['accessToken'],
          'message': responseBody['message'],
        };
      } else {
        final errorResponse = json.decode(response.body);
        return {
          'success': false,
          'message': errorResponse['error'],
        };
      }
    } catch (error) {
      print('Error occurred during login: $error');
      return {
        'success': false,
        'message': 'Login failed due to an error',
      };
    }
  }
}
