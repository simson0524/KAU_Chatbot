import 'dart:convert';
import 'package:http/http.dart' as http;

class NoticeBoardApi {
  static const String baseUrl = 'http://3.37.153.10:3000'; // 서버의 기본 URL

  // 학교 게시판 목록 조회
  // NoticeBoardApi.dart 내부
  static Future<List<Map<String, dynamic>>> getSchoolNotices(
      String accessToken) async {
    final url = Uri.parse('$baseUrl/data/school');
    try {
      print("[DEBUG] Making GET request to: $url");
      print("[DEBUG] With access token: $accessToken");

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      print("[DEBUG] Response status: ${response.statusCode}");
      print("[DEBUG] Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception(
            "Failed to fetch school notices. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("[ERROR] Exception in getSchoolNotices: $e");
      throw e;
    }
  }

  // 학교 게시판 상세 조회
  static Future<Map<String, dynamic>> getSchoolNoticeDetail(
      String idx, String accessToken) async {
    final url = Uri.parse('$baseUrl/data/school/$idx');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> noticeDetail = json.decode(response.body);
      return {
        'idx': noticeDetail['idx'],
        'text': noticeDetail['text'],
        'title': noticeDetail['title'],
        'published_date': noticeDetail['published_date'],
        'url': noticeDetail['url'],
      };
    } else {
      throw Exception(
          'Failed to fetch school notice detail. Status code: ${response.statusCode}');
    }
  }

  // 외부 게시판 목록 조회
  static Future<List<Map<String, dynamic>>> getExternalNotices(
      String accessToken) async {
    final url = Uri.parse('$baseUrl/data/external');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> notices = json.decode(response.body);
      return notices.map((notice) {
        return {
          'idx': notice['idx'],
          'title': notice['title'],
          'dDAY': notice['dDAY'],
        };
      }).toList();
    } else {
      throw Exception(
          'Failed to fetch external notices. Status code: ${response.statusCode}');
    }
  }

  // 외부 게시판 상세 조회
  static Future<Map<String, dynamic>> getExternalNoticeDetail(
      String idx, String accessToken) async {
    final url = Uri.parse('$baseUrl/data/external/$idx');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> noticeDetail = json.decode(response.body);
      return {
        'idx': noticeDetail['idx'],
        'text': noticeDetail['text'],
        'title': noticeDetail['title'],
        'dDAY': noticeDetail['dDAY'],
      };
    } else {
      throw Exception(
          'Failed to fetch external notice detail. Status code: ${response.statusCode}');
    }
  }
}
