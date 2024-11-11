import 'package:sqflite/sqflite.dart';
import 'chat_database.dart';

class ChatDao {
  // Function to insert a message into SQLite
  Future<void> insertMessage(String message, String sender, String timestamp,
      int chatId, String character) async {
    final db = await ChatDatabase.instance.database;

    await db.insert(
      'chatMessages',
      {
        'message': message,
        'sender': sender,
        'timestamp': timestamp,
        'chatId': chatId,
        'character': character, // character 값이 누락되지 않도록 포함시킴
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Message inserted into SQLite: $message by $sender at $timestamp");
  }

  // Function to fetch messages based on chatId
  Future<List<Map<String, dynamic>>> fetchMessages(int chatId) async {
    final db = await ChatDatabase.instance.database;
    return await db.query(
      'chatMessages',
      where: 'chatId = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<int> getNewChatId() async {
    final db = await ChatDatabase.instance.database;
    final result =
        await db.rawQuery('SELECT MAX(chatId) as chatId FROM chatMessages');
    return (result.first['chatId'] as int?)?.toInt() ?? 0; // 기본값을 1로 설정
  }

  // Clear all messages for a given chatId
  Future<void> clearMessages(int chatId) async {
    final db = await ChatDatabase.instance.database;
    await db.delete(
      'chatMessages',
      where: 'chatId = ?',
      whereArgs: [chatId],
    );
  }
}
