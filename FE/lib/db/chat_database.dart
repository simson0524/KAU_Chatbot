import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChatDatabase {
  // 싱글톤 패턴을 사용하여 인스턴스 관리
  static final ChatDatabase instance = ChatDatabase._init();
  static Database? _database;

  ChatDatabase._init();

  // 데이터베이스 인스턴스를 가져오는 함수
  Future<Database> get database async {
    // 데이터베이스가 이미 열려 있으면 해당 인스턴스를 반환
    if (_database != null) return _database!;

    // 데이터베이스를 초기화하고 반환
    _database = await _initDB('chat.db');
    return _database!;
  }

  // 데이터베이스 초기화 함수
  Future<Database> _initDB(String filePath) async {
    // 데이터베이스 파일의 경로를 가져옴
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // 데이터베이스를 열고 생성
    return await openDatabase(
      path, // 데이터베이스 파일 경로
      version: 1, // 데이터베이스 버전
      onCreate: _createDB, // 처음 데이터베이스가 생성될 때 호출되는 함수
    );
  }

  // 데이터베이스 테이블 생성 함수
  Future<void> _createDB(Database db, int version) async {
    // 테이블 스키마 정의
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT'; // 자동 증가하는 ID
    const textType = 'TEXT NOT NULL'; // 필수적인 텍스트 데이터

    // 'chatMessages' 테이블 생성 쿼리
    await db.execute('''
CREATE TABLE chatMessages (
  id $idType,         // 각 메시지의 고유 ID
  message $textType,  // 메시지 내용
  sender $textType,   // 메시지 발신자 (사용자 또는 AI)
  timestamp $textType // 메시지 전송 시간
)
    ''');
  }

  // 데이터베이스 연결을 종료하는 함수
  Future<void> close() async {
    final db = await instance.database;

    // 데이터베이스 연결 종료
    db.close();
  }
}
