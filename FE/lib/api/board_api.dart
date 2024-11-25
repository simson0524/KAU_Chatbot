import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert';

class BoardApi {
  static const String baseUrl = 'http://3.37.153.10:3000';

  // 학과별 게시판 목록 조회
  static Future<http.Response> getMajorBoardList(
      String major, String accessToken) async {
    final url = Uri.parse('$baseUrl/boards/major/$major');
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  // 학과별 게시판 상세 조회
  static Future<http.Response> getMajorBoardDetail(
      String major, int boardId, String accessToken) async {
    final url = Uri.parse('$baseUrl/boards/major/$major/$boardId');
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  // 학과별 게시판 생성
  static Future<http.Response> createMajorBoard(
      String major, String accessToken, String title, String content) async {
    final url = Uri.parse('$baseUrl/boards/major/$major');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'title': title,
        'content': content,
      }),
    );
  }

  // 학과별 게시판 수정
  static Future<http.Response> updateMajorBoard(String major, int boardId,
      String accessToken, String title, String content) async {
    final url = Uri.parse('$baseUrl/boards/major/$major/$boardId');
    return await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'title': title,
        'content': content,
      }),
    );
  }

  // 학과별 게시판 삭제
  static Future<http.Response> deleteMajorBoard(
      String major, int boardId, String accessToken) async {
    final url = Uri.parse('$baseUrl/boards/major/$major/$boardId');
    return await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  // 학번별 게시글 목록 조회
  static Future<http.Response> getStudentBoardList(
      int studentId, String accessToken) async {
    final url = Uri.parse('$baseUrl/board/studentId/$studentId');
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  // 학번별 게시글 상세 조회
  static Future<http.Response> getStudentBoardDetail(
      int studentId, int postId, String accessToken) async {
    final url = Uri.parse('$baseUrl/board/studentId/$studentId/$postId');
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  // 학번별 게시글 작성
  static Future<http.Response> createStudentBoard(
      int studentId, String accessToken, String title, String content) async {
    final url = Uri.parse('$baseUrl/board/studentId/$studentId');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'title': title,
        'content': content,
      }),
    );
  }

  // 댓글 작성
  static Future<http.Response> addComment(
      int studentId, int postId, String accessToken, String comment) async {
    final url = Uri.parse(
        '$baseUrl/board/studentId/$studentId/$postId/comments'); // 올바른 경로로 수정
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({'content': comment}), // 요청 본문에 댓글 내용 포함
    );
  }

  // 게시글 삭제
  static Future<http.Response> deleteStudentBoard(
      int studentId, int postId, String accessToken) async {
    final url = Uri.parse('$baseUrl/board/studentId/$studentId/$postId');
    return await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }
}
