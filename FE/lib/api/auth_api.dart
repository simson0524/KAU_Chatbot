import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthApi {
  // 회원가입 API 호출 함수
  static Future<http.Response> register(
    int studentId,
    String email,
    String password,
    String name,
    String major,
    int grade,
    String gender,
    String residence,
  ) async {
    final url = Uri.parse('http://10.0.2.2:3000/user/register');

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
          'residence': residence,
        }),
      );

      return response; // statusCode와 응답 본문을 포함하여 반환
    } catch (error) {
      print('Error occurred during registration: $error');
      throw Exception('회원가입 중 오류가 발생했습니다.');
    }
  }

  // 이메일 인증번호 전송 API 호출 함수
  static Future<http.Response> sendEmailVerification(String email) async {
    final url = Uri.parse('http://10.0.2.2:3000/user/send-email');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      return response; // statusCode와 응답 본문을 포함하여 반환
    } catch (error) {
      print('Error occurred while sending verification email: $error');
      throw Exception('이메일 인증 중 오류가 발생했습니다.');
    }
  }

  // 이메일 인증번호 확인 API 호출 함수
  static Future<http.Response> verifyEmailCode(String email, int code) async {
    final url = Uri.parse('http://10.0.2.2:3000/user/verify-email');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'code': code,
        }),
      );

      return response; // statusCode와 응답 본문을 포함하여 반환
    } catch (error) {
      print('Error occurred while verifying email: $error');
      throw Exception('이메일 인증 중 오류가 발생했습니다.');
    }
  }

  // 로그인 API 호출 함수
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('http://10.0.2.2:3000/user/login');

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
