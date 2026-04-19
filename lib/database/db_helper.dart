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
}