import 'package:sqflite/sqflite.dart';

/// DatabaseService - Handles local SQLite database operations
/// 
/// Provides:
/// - Database initialization
/// - Table creation
/// - Database migrations
/// - CRUD helpers
class DatabaseService {
  static Database? _database;
  static const String _dbName = 'finance_tracker.db';
  static const int _dbVersion = 1;

  /// Get the database instance (initializes if needed)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$_dbName';

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables on first run
  static Future<void> _onCreate(Database db, int version) async {
    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        notes TEXT,
        date TEXT NOT NULL,
        is_expense INTEGER NOT NULL DEFAULT 1,
        is_synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT,
        is_expense INTEGER NOT NULL DEFAULT 1,
        user_id TEXT,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_transactions_user_id ON transactions(user_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_date ON transactions(date)
    ''');
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations will go here
    // if (oldVersion < 2) { ... }
  }

  /// Insert default expense and income categories
  static Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      // Expense categories
      {'id': 'cat_food', 'name': 'Food', 'icon': 'restaurant', 'is_expense': 1, 'is_default': 1},
      {'id': 'cat_transport', 'name': 'Transport', 'icon': 'directions_car', 'is_expense': 1, 'is_default': 1},
      {'id': 'cat_shopping', 'name': 'Shopping', 'icon': 'shopping_bag', 'is_expense': 1, 'is_default': 1},
      {'id': 'cat_entertainment', 'name': 'Entertainment', 'icon': 'movie', 'is_expense': 1, 'is_default': 1},
      {'id': 'cat_utilities', 'name': 'Utilities', 'icon': 'flash_on', 'is_expense': 1, 'is_default': 1},
      {'id': 'cat_health', 'name': 'Health', 'icon': 'medical_services', 'is_expense': 1, 'is_default': 1},
      // Income categories
      {'id': 'cat_income', 'name': 'Income', 'icon': 'work', 'is_expense': 0, 'is_default': 1},
      {'id': 'cat_investment', 'name': 'Investment', 'icon': 'trending_up', 'is_expense': 0, 'is_default': 1},
      {'id': 'cat_other', 'name': 'Other', 'icon': 'category', 'is_expense': 1, 'is_default': 1},
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  /// Close the database connection
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Delete all data (for testing or user logout)
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
  }
}
