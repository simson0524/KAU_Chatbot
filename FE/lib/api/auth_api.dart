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
    final url =
        Uri.parse('http://localhost:3000/user/register'); // 회원가입 API URL

    try {
      // API 요청 본문 작성
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'}, // JSON 요청 헤더 설정
        body: json.encode({
          'student_id': studentId, // 학번
          'email': email, // 이메일
          'password': password, // 비밀번호
          'name': name,
          'major': major,
          'grade': grade,
          'gender': gender,
          'residence': residence
        }),
      );

      // 응답을 반환하여 statusCode 및 body 확인 가능
      return response;
    } catch (error) {
      print('Error occurred during registration: $error');
      throw Exception('Registration failed');
    }
  }

  // 로그인 API 호출 함수
  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('http://localhost:3000/user/login'); // 로그인 API URL

    try {
      // API 요청 본문 작성
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'}, // JSON 요청 헤더 설정
        body: json.encode({
          'email': email, // 이메일
          'password': password, // 비밀번호
        }),
      );

      // 응답을 반환하여 statusCode 및 body 확인 가능
      return response;
    } catch (error) {
      print('Error occurred during login: $error');
      throw Exception('Login failed');
    }
  }

  // 로그아웃 API 호출 함수
  static Future<http.Response> logout() async {
    final url = Uri.parse('http://localhost:3000/user/logout'); // 로그아웃 API URL

    try {
      // API 요청 본문 작성
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'}, // JSON 요청 헤더 설정
      );

      // 응답을 반환하여 statusCode 및 body 확인 가능
      return response;
    } catch (error) {
      print('Error occurred during logout: $error');
      throw Exception('Logout failed');
    }
  }

  // 비밀번호 변경 API 호출 함수
  static Future<http.Response> changePassword(
      String userId, String newPassword) async {
    final url =
        Uri.parse('http://localhost:3000/user/$userId'); // 비밀번호 변경 API URL

    try {
      // API 요청 본문 작성
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'}, // JSON 요청 헤더 설정
        body: json.encode({
          'user_id': userId, // 사용자 ID
          'password': newPassword, // 새 비밀번호
        }),
      );

      // 응답을 반환하여 statusCode 및 body 확인 가능
      return response;
    } catch (error) {
      print('Error occurred during password change: $error');
      throw Exception('Password change failed');
    }
  }
}
