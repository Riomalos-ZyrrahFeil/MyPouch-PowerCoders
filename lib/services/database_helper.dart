import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

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
      version: 4, 
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
        bio TEXT, 
        image_path TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

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

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        date TEXT NOT NULL,
        is_read INTEGER DEFAULT 0
      )
    ''');
    
    debugPrint('=== DATABASE TABLES CREATED SUCCESSFULLY ===');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("=== UPGRADING DATABASE from $oldVersion to $newVersion ===");
    
    Future<bool> tableExists(String table) async {
      var res = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='$table'");
      return res.isNotEmpty;
    }

    Future<bool> columnExists(String tableName, String columnName) async {
      var res = await db.rawQuery("PRAGMA table_info($tableName)");
      return res.any((row) => row['name'] == columnName);
    }

    if (!await tableExists('notifications')) {
      await db.execute('''
        CREATE TABLE notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          date TEXT NOT NULL,
          is_read INTEGER DEFAULT 0
        )
      ''');
      debugPrint("Created notifications table");
    }

    if (await tableExists('contributions')) {
      if (!await columnExists('contributions', 'source')) {
        try { await db.execute('ALTER TABLE contributions ADD COLUMN source TEXT'); } catch (_) {}
      }
    }
    
    if (await tableExists('users')) {
      if (!await columnExists('users', 'bio')) {
        try { await db.execute('ALTER TABLE users ADD COLUMN bio TEXT'); } catch (_) {}
      }
      if (!await columnExists('users', 'image_path')) {
        try { await db.execute('ALTER TABLE users ADD COLUMN image_path TEXT'); } catch (_) {}
      }
    }
  }

  // --- CORE METHODS ---

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

  // --- GOAL METHODS ---

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

  // --- CONTRIBUTION METHODS ---

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
        SELECT c.id, c.amount, c.created_at, c.source, g.title as goal_title 
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

  // --- STATS METHODS ---

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

    if (firstDeposit.isEmpty || firstDeposit.first['first_day'] == null || total == 0) return 0.0;

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

  // Update Profile
  Future<int> updateUserProfile({String? nickname, String? bio, String? imagePath}) async {
    final db = await database;
    final userId = await getUserId();
    if (userId == null) return 0;

    Map<String, dynamic> updateData = {
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (nickname != null) updateData['nickname'] = nickname;
    if (bio != null) updateData['bio'] = bio;
    if (imagePath != null) updateData['image_path'] = imagePath;
    
    return await db.update('users', updateData, where: 'id = ?', whereArgs: [userId]);
  }

  // Update Security Question
  Future<void> updateSecurityQuestion(String question, String answer) async {
    final db = await database;
    final userId = await getUserId();
    
    if (userId != null) {
      await db.update('users', {
          'security_question': question,
          'security_answer': answer,
          'updated_at': DateTime.now().toIso8601String(),
        }, where: 'id = ?', whereArgs: [userId]);
    }
  }

  // Export CSV (For Excel viewing)
  Future<String> exportDataToCsv() async {
    final db = await database;
    final goals = await db.query('goals');
    final contribs = await db.query('contributions');

    String csv = "TYPE,ID,TITLE_OR_GOALID,AMOUNT,DATE,NOTE_OR_STATUS\n";

    for (var g in goals) {
      csv += "GOAL,${g['id']},${g['title']},${g['target_amount']},${g['created_at']},${g['status']}\n";
    }
    for (var c in contribs) {
      csv += "CONTRIB,${c['id']},${c['goal_id']},${c['amount']},${c['created_at']},${c['note']}\n";
    }
    return csv;
  }

  // Export JSON (For Backup File)
  Future<String> exportDataToJson() async {
    final db = await database;
    Map<String, dynamic> data = {};
    
    data['users'] = await db.query('users');
    data['goals'] = await db.query('goals');
    data['contributions'] = await db.query('contributions');
    
    return jsonEncode(data);
  }

Future<void> importDataFromJson(String jsonString) async {
    final db = await database;
    final data = jsonDecode(jsonString);
    
    final currentUserId = await getUserId();
    if (currentUserId == null) throw Exception("No active user found to restore data to.");

    await db.transaction((txn) async {
      await txn.delete('contributions');
      await txn.delete('goals');
      
      if (data['goals'] != null) {
        for (var item in data['goals']) {
          final Map<String, dynamic> goal = Map<String, dynamic>.from(item);
          
          goal['user_id'] = currentUserId; 
          
          await txn.insert('goals', goal);
        }
      }

      if (data['contributions'] != null) {
        for (var item in data['contributions']) {
          await txn.insert('contributions', item);
        }
      }
    });
  }

  Future<int> addNotification(String title, String body) async {
    final db = await database;
    return await db.insert('notifications', {
      'title': title,
      'body': body,
      'date': DateTime.now().toIso8601String(),
      'is_read': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final db = await database;
    return await db.query('notifications', orderBy: 'date DESC');
  }
}