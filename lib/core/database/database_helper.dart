import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Database get db {
    assert(_db != null, 'Base de datos no inicializada. Llama initialize() primero.');
    return _db!;
  }

  static Future<void> initialize() async {
    // En escritorio (Windows, Linux, macOS) se usa el backend FFI
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'dayflow.db');

    instance._db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        priority TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE hydration (
        date TEXT PRIMARY KEY,
        glasses INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE mood (
        date TEXT PRIMARY KEY,
        moodType TEXT NOT NULL,
        note TEXT,
        registeredAt TEXT NOT NULL
      )
    ''');
  }

  // ─── Tareas ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTasks() async {
    return db.query('tasks');
  }

  Future<void> insertTask(Map<String, dynamic> task) async {
    await db.insert('tasks', task, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTask(Map<String, dynamic> task) async {
    await db.update(
      'tasks',
      task,
      where: 'id = ?',
      whereArgs: [task['id']],
    );
  }

  Future<void> deleteTask(String id) async {
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Hidratación ─────────────────────────────────────────────────────────

  Future<int> getHydrationForToday() async {
    final today = _todayString();
    final rows = await db.query('hydration', where: 'date = ?', whereArgs: [today]);
    if (rows.isEmpty) return 0;
    return rows.first['glasses'] as int;
  }

  Future<void> upsertHydration(int glasses) async {
    await db.insert(
      'hydration',
      {'date': _todayString(), 'glasses': glasses},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── Mood ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getMoodForToday() async {
    final rows = await db.query('mood', where: 'date = ?', whereArgs: [_todayString()]);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<void> upsertMood(Map<String, dynamic> mood) async {
    await db.insert(
      'mood',
      {'date': _todayString(), ...mood},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMoodForToday() async {
    await db.delete('mood', where: 'date = ?', whereArgs: [_todayString()]);
  }

  // ─── Utilidades ──────────────────────────────────────────────────────────

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
