import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  // 싱글톤 패턴으로 인스턴스 반환
  factory DatabaseHelper() {
    return _instance;
  }

  // 데이터베이스 인스턴스 반환 (없으면 생성)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 데이터베이스 초기화 및 생성
  Future<Database> _initDatabase() async {
    // 데이터베이스 파일 경로 설정
    String path = join(await getDatabasesPath(), 'music_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  // 테이블 생성 함수
  Future<void> _createTables(Database db, int version) async {
    // 카테고리 테이블 생성
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // 노래 테이블 생성 (즐겨찾기 컬럼 포함)
    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        singer TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // 기본 카테고리 데이터 삽입
    await _insertDefaultCategories(db);
  }

  // 기본 카테고리 데이터 삽입
  Future<void> _insertDefaultCategories(Database db) async {
    List<String> defaultCategories = [
      'K-POP',
      'POP',
      '발라드',
      '힙합',
      '록',
      '인디',
      'OST',
    ];

    for (String categoryName in defaultCategories) {
      await db.insert('categories', {'name': categoryName});
    }
  }

  // === 카테고리 관련 메서드 ===

  // 모든 카테고리 조회
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'name ASC');
  }

  // 카테고리 추가
  Future<int> insertCategory(String name) async {
    final db = await database;
    return await db.insert('categories', {'name': name});
  }

  // 카테고리 삭제
  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // === 노래 관련 메서드 ===

  // 모든 노래 조회
  Future<List<Map<String, dynamic>>> getAllSongs() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT songs.*, categories.name as category_name 
      FROM songs 
      JOIN categories ON songs.category_id = categories.id 
      ORDER BY songs.name ASC
    ''');
  }

  // 카테고리별 노래 조회
  Future<List<Map<String, dynamic>>> getSongsByCategory(int categoryId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT songs.*, categories.name as category_name 
      FROM songs 
      JOIN categories ON songs.category_id = categories.id 
      WHERE songs.category_id = ? 
      ORDER BY songs.name ASC
    ''', [categoryId]);
  }

  // 즐겨찾기 노래 조회
  Future<List<Map<String, dynamic>>> getFavoriteSongs() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT songs.*, categories.name as category_name 
      FROM songs 
      JOIN categories ON songs.category_id = categories.id 
      WHERE songs.is_favorite = 1 
      ORDER BY songs.name ASC
    ''');
  }

  // 노래 검색
  Future<List<Map<String, dynamic>>> searchSongs(String query) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT songs.*, categories.name as category_name 
      FROM songs 
      JOIN categories ON songs.category_id = categories.id 
      WHERE songs.name LIKE ? OR songs.singer LIKE ? 
      ORDER BY songs.name ASC
    ''', ['%$query%', '%$query%']);
  }

  // 노래 추가
  Future<int> insertSong({
    required int categoryId,
    required String name,
    required String singer,
    bool isFavorite = false,
  }) async {
    final db = await database;
    return await db.insert('songs', {
      'category_id': categoryId,
      'name': name,
      'singer': singer,
      'is_favorite': isFavorite ? 1 : 0,
    });
  }

  // 노래 수정
  Future<int> updateSong({
    required int id,
    required int categoryId,
    required String name,
    required String singer,
    required bool isFavorite,
  }) async {
    final db = await database;
    return await db.update(
      'songs',
      {
        'category_id': categoryId,
        'name': name,
        'singer': singer,
        'is_favorite': isFavorite ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 즐겨찾기 상태 토글
  Future<int> toggleFavorite(int songId) async {
    final db = await database;

    // 현재 즐겨찾기 상태 확인
    List<Map<String, dynamic>> result = await db.query(
      'songs',
      columns: ['is_favorite'],
      where: 'id = ?',
      whereArgs: [songId],
    );

    if (result.isNotEmpty) {
      int currentFavorite = result.first['is_favorite'];
      int newFavorite = currentFavorite == 1 ? 0 : 1;

      return await db.update(
        'songs',
        {'is_favorite': newFavorite},
        where: 'id = ?',
        whereArgs: [songId],
      );
    }
    return 0;
  }

  // 노래 삭제
  Future<int> deleteSong(int id) async {
    final db = await database;
    return await db.delete('songs', where: 'id = ?', whereArgs: [id]);
  }

  // === 유틸리티 메서드 ===

  // 데이터베이스 닫기
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }

  // 데이터베이스 삭제 (개발용)
  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'music_app.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
