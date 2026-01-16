import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_pouch.db');

    debugPrint('=== DATABASE INITIALIZATION ===');
    debugPrint('Database path: $path');

    return openDatabase(
      path,
      version: 2, // CHANGED TO 2 TO FORCE UPDATE/CREATION
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) {
        debugPrint('✓ Database opened successfully');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('=== CREATING TABLES ===');
    
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nickname TEXT NOT NULL,
        pin TEXT NOT NULL,
        security_question TEXT NOT NULL,
        security_answer TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Goals table
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        target_amount REAL NOT NULL,
        current_amount REAL DEFAULT 0,
        image_path TEXT,
        status TEXT DEFAULT 'active',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Contributions table (Includes 'source')
    await db.execute('''
      CREATE TABLE contributions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        source TEXT, -- Added for Money Source feature
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE
      )
    ''');
    
    debugPrint('=== DATABASE TABLES CREATED SUCCESSFULLY ===');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("=== UPGRADING DATABASE from $oldVersion to $newVersion ===");
    
    var tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    var tableNames = tables.map((t) => t['name']).toList();

    if (!tableNames.contains('users')) {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nickname TEXT NOT NULL,
          pin TEXT NOT NULL,
          security_question TEXT NOT NULL,
          security_answer TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    }

    if (!tableNames.contains('goals')) {
      await db.execute('''
        CREATE TABLE goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          target_amount REAL NOT NULL,
          current_amount REAL DEFAULT 0,
          image_path TEXT,
          status TEXT DEFAULT 'active',
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
    }

    if (!tableNames.contains('contributions')) {
      await db.execute('''
        CREATE TABLE contributions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          goal_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          note TEXT,
          source TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE
        )
      ''');
    } else {
      // If table exists but might be missing 'source', try adding it
      try {
        await db.execute('ALTER TABLE contributions ADD COLUMN source TEXT');
      } catch (e) {
        debugPrint("Column 'source' likely already exists: $e");
      }
    }
  }

  // --- METHODS ---

  Future<int> saveUserProfile({ 
    required String nickname,
    required String pin,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    final db = await database;
    return await db.insert('users', {
      'nickname': nickname,
      'pin': pin,
      'security_question': securityQuestion,
      'security_answer': securityAnswer,
    });
  }

  Future<bool> checkUserExists() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
      final count = Sqflite.firstIntValue(result) ?? 0;
      return count > 0;
    } catch (e) {
      debugPrint("Error checking user: $e");
      return false;
    }
  }

  Future<bool> userProfileExists() async => checkUserExists();

  Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> verifyPin(String pin) async {
    final db = await database;
    final result = await db.rawQuery('SELECT id FROM users WHERE pin = ? LIMIT 1', [pin]);
    return result.isNotEmpty;
  }

  Future<String?> getSecurityQuestion() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty ? result.first['security_question'] as String? : null;
  }

  Future<bool> verifySecurityAnswer(String answer) async {
    final db = await database;
    final result = await db.query('users', where: 'security_answer = ?', whereArgs: [answer], limit: 1);
    return result.isNotEmpty;
  }

  Future<int> updatePin(String newPin) async {
    final db = await database;
    final userId = await getUserId();
    if (userId == null) throw Exception('User not found');
    return await db.update('users', {'pin': newPin, 'updated_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> addGoal({
    required String title,
    required String description,
    required double targetAmount,
    String? imagePath,
  }) async {
    final db = await database;
    final user = await getUserProfile();
    if (user == null) throw Exception('User profile not found');

    return await db.insert('goals', {
      'user_id': user['id'],
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'image_path': imagePath,
    });
  }

  Future<List<Map<String, dynamic>>> getAllGoals() async {
    final db = await database;
    final user = await getUserProfile();
    if (user == null) return [];

    return await db.query('goals', where: 'user_id = ? AND status = ?', whereArgs: [user['id'], 'active'], orderBy: 'created_at DESC');
  }

  // "General Savings" Goal ID
  Future<int> getGeneralSavingsGoalId() async {
    final db = await database;
    
    final result = await db.query('goals', where: "title = ?", whereArgs: ['General Savings'], limit: 1);
    
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    } else {
      final user = await getUserProfile();
      if (user == null) throw Exception("Cannot create General Savings: User not found");

      return await db.insert('goals', {
        'user_id': user['id'],
        'title': 'General Savings',
        'description': 'Unallocated savings',
        'target_amount': 0.0, 
        'current_amount': 0.0,
        'image_path': 'assets/logo.png', 
        'status': 'active'
      });
    }
  }

  // Updated to include SOURCE parameter
  Future<int> addContribution({
    required int goalId,
    required double amount,
    String? note,
    String source = 'Cash',
  }) async {
    final db = await database;

    final contributionId = await db.insert('contributions', {
      'goal_id': goalId,
      'amount': amount,
      'note': note,
      'source': source,
    });

    await db.rawUpdate('UPDATE goals SET current_amount = current_amount + ? WHERE id = ?', [amount, goalId]);

    return contributionId;
  }

  Future<List<Map<String, dynamic>>> getContributions(int goalId) async {
    final db = await database;
    return await db.query('contributions', where: 'goal_id = ?', whereArgs: [goalId], orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getGoalDetails(int goalId) async {
    final db = await database;
    final result = await db.query('goals', where: 'id = ?', whereArgs: [goalId], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<double> getTotalBalance() async {
    final db = await database;
    final result = await db.rawQuery("SELECT SUM(current_amount) as total FROM goals WHERE status = 'active'");
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.id, c.amount, c.created_at, c.source, g.title as goal_title, g.image_path, c.note
      FROM contributions c
      INNER JOIN goals g ON c.goal_id = g.id
      ORDER BY c.created_at DESC
    ''');
  }

  Future<int> updateGoal({
    required int id,
    required String title,
    required double targetAmount,
    required String imagePath,
  }) async {
    final db = await database;
    return await db.update('goals', {
      'title': title,
      'target_amount': targetAmount,
      'image_path': imagePath,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> closeDatabase() async => (await database).close();
  Future<void> deleteDatabaseFile() async { _database?.close(); _database = null; }
  
  Future<String?> getCurrentPin() async {
    try {
      final db = await database;
      final result = await db.query('users', limit: 1);
      return result.isNotEmpty ? result.first['pin'] as String? : null;
    } catch (e) { return null; }
  }

  Future<int?> getUserId() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT id FROM users LIMIT 1');
      return result.isNotEmpty ? result.first['id'] as int? : null;
    } catch (e) { return null; }
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('contributions');
    await db.delete('goals');
    await db.delete('users');
  }
  
  Future<void> reinitializeDatabase() async {
    await _database?.close();
    _database = null;
    _database = await _initDatabase();
  }

  Future<Map<int, double>> getWeeklyActivity() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT strftime('%w', created_at) as day_index, SUM(amount) as total
      FROM contributions
      WHERE created_at BETWEEN ? AND ?
      GROUP BY day_index
    ''', [startOfWeek.toIso8601String(), endOfWeek.add(const Duration(days: 1)).toIso8601String()]);

    Map<int, double> activity = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    for (var row in result) {
      int dbDay = int.parse(row['day_index'].toString());
      int weekDay = dbDay == 0 ? 7 : dbDay;
      activity[weekDay] = (row['total'] as num).toDouble();
    }
    return activity;
  }

  Future<Map<String, double>> getGoalDistribution() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT g.title, SUM(c.amount) as total
      FROM contributions c
      JOIN goals g ON c.goal_id = g.id
      GROUP BY g.title
    ''');

    Map<String, double> distribution = {};
    for (var row in result) {
      distribution[row['title'].toString()] = (row['total'] as num).toDouble();
    }
    return distribution;
  }

  Future<int> getStreak() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT date(created_at) as day
      FROM contributions
      ORDER BY day DESC
    ''');

    if (result.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();
    String todayStr = checkDate.toIso8601String().split('T')[0];
    bool todaySaved = result.any((row) => row['day'] == todayStr);

    if (!todaySaved) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    for (var row in result) {
      String dbDate = row['day'].toString();
      String expectedDate = checkDate.toIso8601String().split('T')[0];

      if (dbDate == expectedDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (DateTime.parse(dbDate).isAfter(checkDate)) {
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<double> getDailyAverage() async {
    final db = await database;
    final firstDeposit = await db.rawQuery('SELECT MIN(created_at) as first_day FROM contributions');
    final total = await getTotalBalance();

    if (firstDeposit.first['first_day'] == null || total == 0) return 0.0;

    DateTime start = DateTime.parse(firstDeposit.first['first_day'].toString());
    int daysDiff = DateTime.now().difference(start).inDays + 1;

    return total / daysDiff;
  }

  Future<void> withdrawFunds(int goalId, double amount) async {
    final db = await database;

    await db.insert('contributions', {
      'goal_id': goalId,
      'amount': -amount,
      'note': 'Goal Achieved! Withdrawn & Enjoyed.',
      'source': 'Pouch',
      'created_at': DateTime.now().toString(),
    });

    await db.rawUpdate(
      'UPDATE goals SET current_amount = 0, updated_at = ? WHERE id = ?',
      [DateTime.now().toString(), goalId],
    );
  }
}