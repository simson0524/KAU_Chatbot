import 'package:sqflite/sqflite.dart';
import 'chat_database.dart';

class ChatDao {
  // SQLite에 메시지 삽입 함수
  Future<void> insertMessage(
      String message, String sender, String timestamp) async {
    final db = await ChatDatabase.instance.database;

    await db.insert(
      'chatMessages',
      {
        'message': message,
        'sender': sender, // 사용자(user) 또는 봇(bot)
        'timestamp': timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Message inserted into SQLite: $message by $sender at $timestamp");
  }

  // SQLite에서 메시지 조회 함수 (최신 메시지부터 순서대로 가져옴)
  Future<List<Map<String, dynamic>>> fetchMessages() async {
    final db = await ChatDatabase.instance.database;
    return await db.query(
      'chatMessages',
      orderBy: 'timestamp DESC',
    );
  }

  // SQLite에서 메시지를 모두 삭제하는 함수 (테이블 초기화)
  Future<void> clearMessages() async {
    final db = await ChatDatabase.instance.database;
    await db.delete('chatMessages');
  }
}
