import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthApi {
  static const String baseUrl = 'http://3.37.153.10:3000';
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
    final url = Uri.parse('http://3.37.153.10:3000/user/register');

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
    final url = Uri.parse('http://3.37.153.10:3000/user/send-email');

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
    final url = Uri.parse('http://3.37.153.10:3000/user/verify-email');

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
    final url = Uri.parse('http://3.37.153.10:3000/user/login');

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
          'accessToken': responseBody['accessToken'],
          'refreshToken': responseBody['refreshToken'],
          'message': responseBody['message'],
        };
      } else {
        final errorResponse = json.decode(response.body);
        return {
          'message': errorResponse['message'],
        };
      }
    } catch (error) {
      print('Error occurred during login: $error');
      return {
        'message': 'Login failed due to an error',
      };
    }
  }

  // 비밀번호 변경 API 호출 함수
  static Future<http.Response> changePassword(
      String currentPassword, String newPassword) async {
    final url = Uri.parse('http://3.37.153.10:3000/user/password');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'passward': currentPassword,
          'new_passward': newPassword,
        }),
      );

      return response; // statusCode와 응답 본문을 포함하여 반환
    } catch (error) {
      print('Error occurred during password change: $error');
      throw Exception('비밀번호 변경 중 오류가 발생했습니다.');
    }
  }

  // 채팅 캐릭터 설정 API 호출 함수
  static Future<http.Response> setChatCharacter(
      String email, String chatCharacter) async {
    final url = Uri.parse('http://3.37.153.10:3000/user/character');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'chat_character': chatCharacter,
        }),
      );

      return response; // statusCode와 응답 본문을 포함하여 반환
    } catch (error) {
      print('Error occurred while setting chat character: $error');
      throw Exception('채팅 캐릭터 설정 중 오류가 발생했습니다.');
    }
  }

  // 회원 정보 가져오기 API 호출 함수
  static Future<Map<String, dynamic>> getUserInfo(String accessToken) async {
    final url = Uri.parse('http://3.37.153.10:3000/user');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Access token 헤더에 추가
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // JSON 데이터 반환
      } else {
        throw Exception('Failed to fetch user info');
      }
    } catch (error) {
      print('Error occurred while fetching user info: $error');
      throw Exception('회원 정보 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 회원 정보 수정 API 호출 함수
  static Future<http.Response> updateUserInfo({
    required String name,
    required String major,
    required int grade,
    required String residence,
    required String chatCharacter,
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl/user');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'name': name,
          'major': major,
          'grade': grade,
          'residence': residence,
          'chat_character': chatCharacter,
        }),
      );

      if (response.statusCode == 200) {
        return response; // Return successful response
      } else {
        throw Exception(
            'Failed to update user info: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error updating user info: $error');
      throw Exception('회원 정보를 수정하는 중 오류가 발생했습니다.');
    }
  }

  // 회원 탈퇴 API 호출 함수
  static Future<http.Response> deleteUser(String accessToken) async {
    final url = Uri.parse('$baseUrl/user');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return response; // Return successful response
      } else {
        throw Exception(
            'Failed to delete user: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error deleting user: $error');
      throw Exception('회원 탈퇴 중 오류가 발생했습니다.');
    }
  }

  // 본인 확인 API
  static Future<Map<String, dynamic>> checkUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/user/check');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to verify user');
    }
  }
}
