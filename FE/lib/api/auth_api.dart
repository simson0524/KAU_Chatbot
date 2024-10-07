import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthApi {
  // 회원가입 API 호출 함수
  static Future<void> register(
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

      // 성공적으로 응답 받았을 때
      if (response.statusCode == 201) {
        // 서버에서 반환된 응답 데이터 처리
        final responseData = json.decode(response.body);
        print('회원가입이 완료되었습니다: ${responseData['user_id']}');
        // 추가 처리 (예: 토큰 저장 등)
      } else {
        // 오류 응답 처리
        print('Register failed: ${response.body}');
      }
    } catch (error) {
      // 네트워크 오류 처리
      print('Error occurred during registration: $error');
    }
  }

  // 로그인 API 호출 함수
  static Future<void> login(String email, String password) async {
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

      // 성공적으로 응답 받았을 때
      if (response.statusCode == 200) {
        // 서버에서 반환된 응답 데이터 처리
        final responseData = json.decode(response.body);
        print('Login successful: ${responseData['user_id']}');
        // 추가 처리 (예: 토큰 저장 등)
      } else {
        // 오류 응답 처리
        print('Login failed: ${response.body}');
      }
    } catch (error) {
      // 네트워크 오류 처리
      print('Error occurred during login: $error');
    }
  }

  // 로그아웃 API 호출 함수
  static Future<void> logout() async {
    final url = Uri.parse('http://your-server.com/user/logout'); // 로그아웃 API URL

    try {
      // API 요청 본문 작성
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'}, // JSON 요청 헤더 설정
      );

      // 성공적으로 응답 받았을 때
      if (response.statusCode == 200) {
        print('Logout successful');
        // 추가 처리 (예: 사용자 정보 삭제 등)
      } else {
        // 오류 응답 처리
        print('Logout failed: ${response.body}');
      }
    } catch (error) {
      // 네트워크 오류 처리
      print('Error occurred during logout: $error');
    }
  }

  // 비밀번호 변경 API 호출 함수
  static Future<void> changePassword(String userId, String newPassword) async {
    final url =
        Uri.parse('http://your-server.com/user/$userId'); // 비밀번호 변경 API URL

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

      // 성공적으로 응답 받았을 때
      if (response.statusCode == 200) {
        print('Password changed successfully');
      } else {
        // 오류 응답 처리
        print('Failed to change password: ${response.body}');
      }
    } catch (error) {
      // 네트워크 오류 처리
      print('Error occurred during password change: $error');
    }
  }
}
