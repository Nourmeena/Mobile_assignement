import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDatabase();
    return _db;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'users_data.db');
    Database db = await openDatabase(
      path, 
      version: 1, 
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT,
            studentId TEXT,
            email TEXT,
            profileImage TEXT
          )
        ''');
      }
    );
    return db;
  }

  Future<int> saveUser(UserModel user) async {
    Database? dbClient = await db;
    return await dbClient!.insert(
      'users', 
      user.toMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<UserModel?> getUser() async {
    Database? dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient!.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }
}