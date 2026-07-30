import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  static const _dbName = 'notegym.db';
  static const _dbVersion = 1;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        tenant_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        tenant_id TEXT,
        date TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE set_logs (
        id TEXT PRIMARY KEY,
        workout_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        weight REAL NOT NULL DEFAULT 0,
        reps INTEGER NOT NULL,
        rir INTEGER,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (workout_id) REFERENCES workouts(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE assessments (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        wellness_score REAL NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values,
    String id,
  ) async {
    final db = await database;
    return await db.update(
      table,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<Map<String, dynamic>?> queryById(String table, String id) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getUnsynced(String table) async {
    final db = await database;
    return await db.query(
      table,
      where: 'is_synced = 0',
    );
  }

  Future<int> markSynced(String table, String id) async {
    return await update(table, {'is_synced': 1}, id);
  }

  Future<void> clearLocalData() async {
    final db = await database;
    await db.delete('set_logs');
    await db.delete('workouts');
    await db.delete('assessments');
    await db.delete('users');
  }

  Future<void> close() async {
    _database?.close();
    _database = null;
    _instance = null;
  }
}
