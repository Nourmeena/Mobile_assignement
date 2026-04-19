import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';

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
      version: 2, 
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
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            dueDate TEXT NOT NULL,
            priority TEXT NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            userId INTEGER
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              description TEXT,
              dueDate TEXT NOT NULL,
              priority TEXT NOT NULL,
              isCompleted INTEGER NOT NULL DEFAULT 0,
              userId INTEGER
            )
          ''');
        }
      },
    );
    return db;
  }

  // الدالة المعدلة لضمان تحديث البيانات والصورة
  Future<int> saveUser(UserModel user) async {
    Database? dbClient = await db;
    
    // تحويل الـ user لـ Map وتثبيت الـ ID بـ 1 
    // ده بيجبر قاعدة البيانات إنها تمسح بيانات الصف الأول وتحط الجديدة مكانها
    Map<String, dynamic> userMap = user.toMap();
    userMap['id'] = 1; 

    return await dbClient!.insert(
      'users', 
      userMap, 
      conflictAlgorithm: ConflictAlgorithm.replace, // استبدال البيانات القديمة بالجديدة
    );
  }

  Future<UserModel?> getUser() async {
    Database? dbClient = await db;
    // جلب الصف رقم 1 دايماً
    List<Map<String, dynamic>> maps = await dbClient!.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // ─── Task operations ─────────────────────────────────────────────────────────

  Future<int> insertTask(TaskModel task) async {
    Database? dbClient = await db;
    return await dbClient!.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TaskModel>> getAllTasks({int? userId}) async {
    Database? dbClient = await db;
    List<Map<String, dynamic>> maps;
    if (userId != null) {
      maps = await dbClient!.query(
        'tasks',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'isCompleted ASC, dueDate ASC',
      );
    } else {
      maps = await dbClient!.query(
        'tasks',
        orderBy: 'isCompleted ASC, dueDate ASC',
      );
    }
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<int> updateTask(TaskModel task) async {
    Database? dbClient = await db;
    return await dbClient!.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    Database? dbClient = await db;
    return await dbClient!.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleTaskCompletion(int id, bool isCompleted) async {
    Database? dbClient = await db;
    return await dbClient!.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
