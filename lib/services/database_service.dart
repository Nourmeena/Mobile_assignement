import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/user_model.dart';

class DatabaseService {
  static Database? _database;

  // only one database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // initialize database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'student_app.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // create tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT,
        email TEXT UNIQUE,
        studentId TEXT,
        password TEXT,
        gender TEXT,
        academicLevel INTEGER,
        imagePath TEXT
      )
    ''');
  }

  // insert user
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  // get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    } else {
      return null;
    }
  }
}
