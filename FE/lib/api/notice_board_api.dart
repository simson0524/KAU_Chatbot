import 'dart:convert';
import 'package:http/http.dart' as http;

class NoticeBoardApi {
  static const String baseUrl = 'http://3.37.153.10:3000'; // 서버의 기본 URL
  static const String localUrl = 'http://10.0.2.2:3000';

  // 학교 게시판 목록 조회
  // NoticeBoardApi.dart 내부
  static Future<List<Map<String, String>>> getSchoolNotices(
      String accessToken) async {
    final url = Uri.parse('http://3.37.153.10:3000/data/school');

    try {
      print('[DEBUG] Making GET request to: $url');
      print('[DEBUG] With access token: $accessToken');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);

        if (decodedBody['notices'] is List) {
          final List<dynamic> notices = decodedBody['notices'];

          // Map<String, dynamic> -> Map<String, String> 변환
          return notices.map((notice) {
            return {
              'idx': notice['idx']?.toString() ?? '',
              'title': notice['title']?.toString() ?? '',
              'published_date': notice['published_date']?.toString() ?? '',
            };
          }).toList();
        } else {
          throw Exception(
              '[ERROR] Expected "notices" to be a List but got ${decodedBody['notices'].runtimeType}');
        }
      } else {
        throw Exception(
            'Failed to fetch school notices. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('[ERROR] Exception in getSchoolNotices: $error');
      throw Exception('Failed to fetch school notices. Error: $error');
    }
  }

  // 학교 게시판 상세 조회
  static Future<Map<String, dynamic>> getSchoolNoticeDetail(
      String idx, String accessToken) async {
    final url = Uri.parse('http://3.37.153.10:3000/data/school/$idx');

    try {
      print("[DEBUG] Request URL: $url");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print("[DEBUG] Response status: ${response.statusCode}");
      print("[DEBUG] Response body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        final notice = decodedBody['notice'];

        if (notice != null) {
          return {
            'idx': notice['idx'] ?? '',
            'title': notice['title'] ?? '',
            'text': notice['text'] ?? '',
            'published_date': notice['published_date'] ?? '',
            'url': notice['url']?.toString() ?? '',
          };
        } else {
          throw Exception("Notice data is missing in response");
        }
      } else {
        throw Exception(
            "Failed to fetch notice detail. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("[ERROR] Exception in getSchoolNoticeDetail: $e");
      throw Exception("Failed to fetch school notice detail. Error: $e");
    }
  }

  // 외부 게시판 목록 조회
  static Future<List<Map<String, String>>> getExternalNotices(
      String accessToken) async {
    final url = Uri.parse('$baseUrl/data/external');

    try {
      print('[DEBUG] Making GET request to: $url');
      print('[DEBUG] With access token: $accessToken');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);

        // "notices"가 List인지 확인 후 처리
        if (decodedBody['notices'] is List) {
          final List<dynamic> notices = decodedBody['notices'];

          return notices.map((notice) {
            // 각 공지를 Map<String, String>으로 변환
            return {
              'idx': notice['idx']?.toString() ?? '',
              'title': notice['title']?.toString() ?? '',
              'deadline_date': notice['deadline_date']?.toString() ?? '',
              'url': notice['url']?.toString() ?? '',
              'dDay': notice['dDay']?.toString() ?? 'N/A',
            };
          }).toList();
        } else {
          throw Exception(
              '[ERROR] Expected "notices" to be a List but got ${decodedBody['notices'].runtimeType}');
        }
      } else {
        throw Exception(
            'Failed to fetch external notices. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('[ERROR] Exception in getExternalNotices: $error');
      throw Exception('Failed to fetch external notices. Error: $error');
    }
  }

  // 외부 게시판 상세 조회
  static Future<Map<String, dynamic>> getExternalNoticeDetail(
      String idx, String accessToken) async {
    final url = Uri.parse('$baseUrl/data/external/$idx');

    try {
      print("[DEBUG] Request URL: $url");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print("[DEBUG] Response status: ${response.statusCode}");
      print("[DEBUG] Response body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        final notice = decodedBody['notice'];

        if (notice != null) {
          // 디버깅 코드 추가
          print("[DEBUG] Notice idx: ${notice['idx']}");
          print("[DEBUG] Notice title: ${notice['title']}");
          print("[DEBUG] Notice text: ${notice['text']}");
          print("[DEBUG] Notice dDAY: ${notice['dDAY']}");
          print("[DEBUG] Notice url: ${notice['url']}");

          return {
            'idx': notice['idx'] ?? '',
            'title': notice['title'] ?? '',
            'text': notice['text'] ?? '',
            'dDAY': notice['dDAY'] ?? '',
            'url': notice['url']?.toString() ?? '',
          };
        } else {
          print("[ERROR] 'notice' field is missing or null in response.");
          throw Exception("Notice data is missing in response");
        }
      } else {
        print(
            "[ERROR] Failed to fetch notice detail. Status code: ${response.statusCode}");
        throw Exception(
            "Failed to fetch external notice detail. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("[ERROR] Exception in getExternalNoticeDetail: $e");
      throw Exception("Failed to fetch external notice detail. Error: $e");
    }
  }
}
