import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChatDatabase {
  // Singleton pattern to manage instance
  static final ChatDatabase instance = ChatDatabase._init();
  static Database? _database;

  ChatDatabase._init();

  // Method to get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('chat.db');
    return _database!;
  }

  // Database initialization function
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Open the database and create tables if necessary
    return await openDatabase(
      path,
      version: 3, // 버전 증가
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute('DROP TABLE IF EXISTS chatMessages');
          await _createDB(db, newVersion);
        }
      },
    );
  }

  // Table creation function
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const intType = 'INTEGER NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE chatMessages (
  id $idType,
  chatId $intType,
  message $textType,
  sender $textType,
  timestamp $textType,
  character $textType
)
    ''');
  }

  // Method to close the database connection
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
