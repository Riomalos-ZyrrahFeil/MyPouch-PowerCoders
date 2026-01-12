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

  /// Force reinitialize the database connection (useful for debugging)
  Future<void> reinitializeDatabase() async {
    await _database?.close();
    _database = null;
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_pouch.db');

    debugPrint('=== DATABASE INITIALIZATION ===');
    debugPrint('Database path: $path');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) {
        debugPrint('✓ Database opened successfully');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('=== CREATING TABLES ===');
    
    // Users table
    debugPrint('Creating users table...');
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
    debugPrint('✓ Users table created');

    // Goals table
    debugPrint('Creating goals table...');
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
    debugPrint('✓ Goals table created');

    // Contributions table
    debugPrint('Creating contributions table...');
    await db.execute('''
      CREATE TABLE contributions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE
      )
    ''');
    debugPrint('✓ Contributions table created');
    debugPrint('=== DATABASE TABLES CREATED SUCCESSFULLY ===');
  }

  /// Save user profile during setup
  Future<int> saveUserProfile({ 
    required String nickname,
    required String pin,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    final db = await database;
    
    debugPrint('=== SAVING USER PROFILE ===');
    debugPrint('Nickname: $nickname');
    debugPrint('PIN: $pin (length: ${pin.length})');
    debugPrint('Security Question: $securityQuestion');
    debugPrint('Security Answer: $securityAnswer');
    
    try {
      final result = await db.insert(
        'users',
        {
          'nickname': nickname,
          'pin': pin,
          'security_question': securityQuestion,
          'security_answer': securityAnswer,
        },
      );
      
      debugPrint('✓ User profile saved with ID: $result');
      
      // Verify the PIN was saved correctly
      final savedPin = await getCurrentPin();
      debugPrint('Verification - PIN in database: $savedPin');
      
      if (savedPin != pin) {
        debugPrint('⚠️ WARNING: PIN mismatch! Expected: $pin, Got: $savedPin');
      }
      
      return result;
    } catch (e) {
      debugPrint('✗ Error saving user profile: $e');
      rethrow;
    }
  }

  /// Check if user profile exists using COUNT query
  Future<bool> checkUserExists() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  /// Check if user profile exists (legacy method)
  Future<bool> userProfileExists() async {
    return checkUserExists();
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  /// Verify PIN - CRITICAL: Always fetch fresh from database
  Future<bool> verifyPin(String pin) async {
    final db = await database;
    try {
      debugPrint('=== VERIFYING PIN ===');
      debugPrint('PIN to verify: $pin (length: ${pin.length})');
      
      // Get all users for debugging
      final allUsers = await db.rawQuery('SELECT id, nickname, pin FROM users');
      debugPrint('Total users in database: ${allUsers.length}');
      for (var user in allUsers) {
        final savedPin = user['pin'] as String?;
        debugPrint('User ID: ${user['id']}, Nickname: ${user['nickname']}, Saved PIN: $savedPin (length: ${savedPin?.length ?? 0})');
      }
      
      // Now verify
      final result = await db.rawQuery(
        'SELECT id FROM users WHERE pin = ? LIMIT 1',
        [pin],
      );
      
      final isValid = result.isNotEmpty;
      debugPrint('PIN verification result: ${isValid ? '✓ VALID' : '✗ INVALID'}');
      
      return isValid;
    } catch (e) {
      debugPrint('✗ Error verifying PIN: $e');
      return false;
    }
  }

  /// Get security question
  Future<String?> getSecurityQuestion() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty ? result.first['security_question'] as String? : null;
  }

  /// Verify security answer
  Future<bool> verifySecurityAnswer(String answer) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'security_answer = ?',
      whereArgs: [answer],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Update PIN after successful recovery - with validation
  Future<int> updatePin(String newPin) async {
    if (newPin.isEmpty || newPin.length != 4) {
      throw Exception('Invalid PIN format');
    }
    
    final db = await database;
    
    // First verify the user exists and get their ID
    final userId = await getUserId();
    if (userId == null) {
      throw Exception('User profile not found');
    }
    
    // Update the PIN
    final result = await db.update(
      'users',
      {
        'pin': newPin,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (result == 0) {
      throw Exception('Failed to update PIN - no rows affected');
    }
    
    // Verify the update was successful by reading back
    final updatedPin = await getCurrentPin();
    if (updatedPin != newPin) {
      throw Exception('PIN verification failed after update');
    }
    
    return result;
  }

  /// Add a new goal
  Future<int> addGoal({
    required String title,
    required String description,
    required double targetAmount,
    String? imagePath,
  }) async {
    final db = await database;
    final user = await getUserProfile();
    
    if (user == null) throw Exception('User profile not found');

    return await db.insert(
      'goals',
      {
        'user_id': user['id'],
        'title': title,
        'description': description,
        'target_amount': targetAmount,
        'image_path': imagePath,
      },
    );
  }

  /// Get all goals for user
  Future<List<Map<String, dynamic>>> getAllGoals() async {
    final db = await database;
    final user = await getUserProfile();
    
    if (user == null) return [];

    return await db.query(
      'goals',
      where: 'user_id = ? AND status = ?',
      whereArgs: [user['id'], 'active'],
      orderBy: 'created_at DESC',
    );
  }

  /// Add contribution to a goal
  Future<int> addContribution({
    required int goalId,
    required double amount,
    String? note,
  }) async {
    final db = await database;

    // Insert contribution
    final contributionId = await db.insert(
      'contributions',
      {
        'goal_id': goalId,
        'amount': amount,
        'note': note,
      },
    );

    // Update goal's current amount
    await db.rawUpdate('''
      UPDATE goals 
      SET current_amount = current_amount + ?
      WHERE id = ?
    ''', [amount, goalId]);

    return contributionId;
  }

  /// Get contributions for a goal
  Future<List<Map<String, dynamic>>> getContributions(int goalId) async {
    final db = await database;
    return await db.query(
      'contributions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'created_at DESC',
    );
  }

  /// Get goal details
  Future<Map<String, dynamic>?> getGoalDetails(int goalId) async {
    final db = await database;
    final result = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [goalId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Close database
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }

  /// Delete database (for debugging)
  Future<void> deleteDatabaseFile() async {
    _database?.close();
    _database = null;
  }

  /// Get current PIN for validation
  Future<String?> getCurrentPin() async {
    try {
      final db = await database;
      final result = await db.query('users', limit: 1);
      if (result.isNotEmpty) {
        return result.first['pin'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get the user's ID (needed for updates)
  Future<int?> getUserId() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT id FROM users LIMIT 1');
      if (result.isNotEmpty) {
        return result.first['id'] as int?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  /// Nuclear Option - Reset entire database and clear preferences
  Future<void> resetDatabase() async {
    try {
      final db = await database;
      
      // Delete all data from tables
      await db.delete('contributions');
      await db.delete('goals');
      await db.delete('users');
    } catch (e) {
      rethrow;
    }
  }

  /// Get total saved amount across all active goals
  Future<double> getTotalBalance() async {
    final db = await database;
    // Sum the 'current_amount' of all active goals
    final result = await db.rawQuery(
      "SELECT SUM(current_amount) as total FROM goals WHERE status = 'active'"
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get ALL contributions sorted by date (Global History)
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    // Join contributions with goals to show which goal the money went to
    return await db.rawQuery('''
      SELECT 
        c.id, 
        c.amount, 
        c.created_at, 
        g.title as goal_title 
      FROM contributions c
      INNER JOIN goals g ON c.goal_id = g.id
      ORDER BY c.created_at DESC
    ''');
  }
}
