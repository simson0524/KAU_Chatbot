import 'package:sqflite/sqflite.dart';
import 'chat_database.dart';

class ChatDao {
  // SQLite에 메시지 삽입 함수
  Future<void> insertMessage(
      String message, String sender, String timestamp) async {
    // 데이터베이스 인스턴스를 가져옴
    final db = await ChatDatabase.instance.database;

    // SQLite에 메시지를 삽입, 동일한 메시지가 있을 경우 덮어씀 (ConflictAlgorithm.replace)
    await db.insert(
      'chatMessages', // 'chatMessages' 테이블에 삽입
      {
        'message': message, // 저장할 메시지
        'sender': sender, // 메시지 발신자
        'timestamp': timestamp, // 메시지 전송 시간
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // 중복된 데이터가 있으면 덮어쓰기
    );
  }

  // SQLite에서 메시지 조회 함수 (최신 메시지부터 순서대로 가져옴)
  Future<List<Map<String, dynamic>>> fetchMessages() async {
    // 데이터베이스 인스턴스를 가져옴
    final db = await ChatDatabase.instance.database;

    // 테이블에서 메시지를 시간 순서대로 조회
    return await db.query(
      'chatMessages', // 'chatMessages' 테이블에서 조회
      orderBy: 'timestamp DESC', // 최신 메시지부터 내림차순으로 정렬
    );
  }

  // SQLite에서 메시지를 모두 삭제하는 함수 (테이블 초기화)
  Future<void> clearMessages() async {
    final db = await ChatDatabase.instance.database;

    // 'chatMessages' 테이블의 모든 데이터를 삭제
    await db.delete('chatMessages');
  }
}
