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


// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// import '../models/user_profilel.dart';
// //import '../models/user_profile_model.dart';
//
// class DBHelper {
//   static final DBHelper instance = DBHelper._init();
//   static Database? _database;
//
//   DBHelper._init();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('user_profile.db');
//     return _database!;
//   }
//
//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);
//
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _createDB,
//     );
//   }
//
//   Future _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE user_profile (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         age INTEGER NOT NULL,
//         cycle_length INTEGER NOT NULL,
//         last_period_date TEXT NOT NULL,
//         predicted_next_period TEXT,
//         predicted_ovulation TEXT
//       )
//     ''');
//   }
//
//   Future<void> insertOrUpdateUserProfile(UserProfileModel profile) async {
//     final db = await instance.database;
//     final existing = await db.query('user_profile');
//
//     if (existing.isEmpty) {
//       await db.insert('user_profile', profile.toMap());
//     } else {
//       await db.update(
//         'user_profile',
//         profile.toMap(),
//         where: 'id = ?',
//         whereArgs: [existing.first['id']],
//       );
//     }
//   }
//
//   Future<UserProfileModel?> getUserProfile() async {
//     final db = await instance.database;
//     final maps = await db.query('user_profile');
//
//     if (maps.isNotEmpty) {
//       return UserProfileModel.fromMap(maps.first);
//     }
//     return null;
//   }
//
//   Future<void> deleteUserProfile() async {
//     final db = await instance.database;
//     await db.delete('user_profile');
//   }
// }
//
//
//
// // import 'package:path/path.dart';
// // import 'package:sqflite/sqflite.dart';
// // //import '../models/user_profile.dart';
// //
// // class DBHelper {
// //   static final DBHelper instance = DBHelper._privateConstructor();
// //   static Database? _database;
// //   DBHelper._privateConstructor();
// //
// //   Future<Database> get database async {
// //     if (_database != null) return _database!;
// //     _database = await _initDatabase();
// //     return _database!;
// //   }
// //
// //   Future<Database> _initDatabase() async {
// //     final dbPath = await getDatabasesPath();
// //     final path = join(dbPath, 'menstrual_health.db');
// //
// //     return await openDatabase(
// //       path,
// //       version: 1,
// //       onCreate: _createDb,
// //     );
// //   }
// //
// //   Future<void> _createDb(Database db, int version) async {
// //     await db.execute('''
// //       CREATE TABLE user_profile (
// //         id INTEGER PRIMARY KEY AUTOINCREMENT,
// //         name TEXT,
// //         age INTEGER,
// //         menstrual_cycle_length INTEGER,
// //         last_period_date TEXT
// //       )
// //     ''');
// //   }
// //
// //   // Insert user profile
// //   Future<int> insertUserProfile(UserProfile profile) async {
// //     final db = await database;
// //     return await db.insert('user_profile', profile.toMap());
// //   }
// //
// //   // Get first (or only) user profile
// //   Future<UserProfile?> getUserProfile() async {
// //     final db = await database;
// //     final List<Map<String, dynamic>> maps = await db.query('user_profile', limit: 1);
// //
// //     if (maps.isNotEmpty) {
// //       return UserProfile.fromMap(maps.first);
// //     }
// //     return null;
// //   }
// //
// //   // Update user profile
// //   Future<int> updateUserProfile(UserProfile profile) async {
// //     final db = await database;
// //     return await db.update(
// //       'user_profile',
// //       profile.toMap(),
// //       where: 'id = ?',
// //       whereArgs: [profile.id],
// //     );
// //   }
// //
// //   // Delete all profiles (optional utility)
// //   Future<int> deleteAllProfiles() async {
// //     final db = await database;
// //     return await db.delete('user_profile');
// //   }
// // }
// //
// //
// //
// // // import 'package:path/path.dart';
// // // import 'package:sqflite/sqflite.dart';
// // // import '../models/user_profilel.dart';  // Import the UserProfile model
// // //
// // // class DBHelper {
// // //   static Database? _database;
// // //   static final DBHelper instance = DBHelper._privateConstructor();
// // //   DBHelper._privateConstructor();
// // //
// // //   Future<Database> get database async {
// // //     if (_database != null) return _database!;
// // //     _database = await _initDatabase();
// // //     return _database!;
// // //   }
// // //
// // //   Future<Database> _initDatabase() async {
// // //     final dbPath = await getDatabasesPath();
// // //     final path = join(dbPath, 'menstrual_health.db');
// // //
// // //     return await openDatabase(
// // //       path,
// // //       version: 1,
// // //       onCreate: _createDb,
// // //     );
// // //   }
// // //
// // //   Future<void> _createDb(Database db, int version) async {
// // //     await db.execute('''
// // //       CREATE TABLE user_profile (
// // //         id INTEGER PRIMARY KEY AUTOINCREMENT,
// // //         name TEXT,
// // //         age INTEGER,
// // //         menstrual_cycle_length INTEGER,
// // //         last_period_date TEXT,
// // //         preferences TEXT
// // //       )
// // //     ''');
// // //   }
// // //
// // //   // Create a new user profile
// // //   Future<int> insertUserProfile(UserProfile profile) async {
// // //     final db = await database;
// // //     return await db.insert('user_profile', profile.toMap());
// // //   }
// // //
// // //   // Get a user profile by ID
// // //   Future<UserProfile?> getUserProfile(int id) async {
// // //     final db = await database;
// // //     final maps = await db.query(
// // //       'user_profile',
// // //       columns: ['id', 'name', 'age', 'menstrual_cycle_length', 'last_period_date', 'preferences'],
// // //       where: 'id = ?',
// // //       whereArgs: [id],
// // //     );
// // //
// // //     if (maps.isNotEmpty) {
// // //       return UserProfile.fromMap(maps.first);
// // //     }
// // //     return null;
// // //   }
// // //
// // //   // Get all user profiles (if needed)
// // //   Future<List<UserProfile>> getAllUserProfiles() async {
// // //     final db = await database;
// // //     final result = await db.query('user_profile');
// // //
// // //     return result.map((map) => UserProfile.fromMap(map)).toList();
// // //   }
// // //
// // //   // Update a user profile
// // //   Future<int> updateUserProfile(UserProfile profile) async {
// // //     final db = await database;
// // //     return await db.update(
// // //       'user_profile',
// // //       profile.toMap(),
// // //       where: 'id = ?',
// // //       whereArgs: [profile.id],
// // //     );
// // //   }
// // //
// // //   // Delete a user profile by ID
// // //   Future<int> deleteUserProfile(int id) async {
// // //     final db = await database;
// // //     return await db.delete(
// // //       'user_profile',
// // //       where: 'id = ?',
// // //       whereArgs: [id],
// // //     );
// // //   }
// // // }
