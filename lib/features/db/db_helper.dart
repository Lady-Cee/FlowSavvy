import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profilel.dart'; // Your UserProfileModel import

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_profile.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Create table when database is created
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        cycleLength INTEGER,
        lastPeriodDate TEXT,
        predictedNextPeriod TEXT,
        predictedOvulation TEXT
      )
    ''');
  }

  // Save or update user profile in the database
  Future<void> insertOrUpdateUserProfile(UserProfileModel profile) async {
    final db = await database;

    await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch the user profile from the database
  Future<UserProfileModel?> getUserProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_profile');

    if (maps.isNotEmpty) {
      return UserProfileModel.fromMap(maps.first);
    } else {
      return null; // No profile found
    }
  }
}



