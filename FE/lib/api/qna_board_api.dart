import 'dart:convert';
import 'package:http/http.dart' as http;

class QnaBoardApi {
  static const String baseUrl = 'http://3.37.153.10:3000';

  // 문의 게시판 목록 조회
  static Future<http.Response> getInquiries(String accessToken) async {
    final url = Uri.parse('$baseUrl/board/inquiries');
    return await http.get(url, headers: _headers(accessToken));
  }

  static Future<http.Response> getInquiryDetails(
      String inquiryId, String accessToken) async {
    final url = Uri.parse('$baseUrl/board/inquiries/$inquiryId');
    print('API URL: $url');
    print('AccessToken: $accessToken');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('Response from API: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // 문의 작성
  static Future<http.Response> createInquiry(String title, String content,
      int departmentId, String accessToken) async {
    final url = Uri.parse('$baseUrl/board/inquiries');
    return await http.post(
      url,
      headers: _headers(accessToken),
      body: json.encode({
        'title': title,
        'content': content,
        'department_id': departmentId,
      }),
    );
  }

  // 댓글 작성 (관리자)
  static Future<http.Response> addComment(
      String inquiryId, String content, String accessToken) async {
    final url = Uri.parse('$baseUrl/board/inquiries/$inquiryId/comments');
    return await http.post(
      url,
      headers: _headers(accessToken),
      body: json.encode({'content': content}),
    );
  }

  // 공통 헤더
  static Map<String, String> _headers(String accessToken) {
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }
}
