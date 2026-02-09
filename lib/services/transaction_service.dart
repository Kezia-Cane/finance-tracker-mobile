import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import 'database_service.dart';

/// TransactionService - CRUD operations for transactions
/// 
/// Handles all transaction-related operations:
/// - Create, Read, Update, Delete
/// - Filtering and searching
/// - Aggregations (totals, summaries)
class TransactionService {
  static const _uuid = Uuid();
  static const String _tableName = 'transactions';

  /// Create a new transaction
  static Future<TransactionModel> create({
    required String userId,
    required String title,
    required double amount,
    required String category,
    String? notes,
    required DateTime date,
    required bool isExpense,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();

    final transaction = TransactionModel(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      amount: amount,
      category: category,
      notes: notes,
      date: date,
      isExpense: isExpense,
      isSynced: false,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(_tableName, transaction.toMap());
    return transaction;
  }

  /// Get all transactions for a user
  static Future<List<TransactionModel>> getAll(String userId) async {
    final db = await DatabaseService.database;
    final results = await db.query(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return results.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Get transactions for a specific date range
  static Future<List<TransactionModel>> getByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await DatabaseService.database;
    final results = await db.query(
      _tableName,
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return results.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Get a single transaction by ID
  static Future<TransactionModel?> getById(String id) async {
    final db = await DatabaseService.database;
    final results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return TransactionModel.fromMap(results.first);
  }

  /// Update an existing transaction
  static Future<TransactionModel> update(TransactionModel transaction) async {
    final db = await DatabaseService.database;
    final updated = transaction.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await db.update(
      _tableName,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    return updated;
  }

  /// Delete a transaction by ID
  static Future<void> delete(String id) async {
    final db = await DatabaseService.database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get total balance for a user
  static Future<double> getTotalBalance(String userId) async {
    final db = await DatabaseService.database;
    
    // Get total income
    final incomeResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM $_tableName 
      WHERE user_id = ? AND is_expense = 0
    ''', [userId]);
    final totalIncome = (incomeResult.first['total'] as num?)?.toDouble() ?? 0;

    // Get total expense
    final expenseResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM $_tableName 
      WHERE user_id = ? AND is_expense = 1
    ''', [userId]);
    final totalExpense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0;

    return totalIncome - totalExpense;
  }

  /// Get income total for a user
  static Future<double> getTotalIncome(String userId) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM $_tableName 
      WHERE user_id = ? AND is_expense = 0
    ''', [userId]);
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  /// Get expense total for a user
  static Future<double> getTotalExpense(String userId) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM $_tableName 
      WHERE user_id = ? AND is_expense = 1
    ''', [userId]);
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  /// Get unsynced transactions
  static Future<List<TransactionModel>> getUnsynced(String userId) async {
    final db = await DatabaseService.database;
    final results = await db.query(
      _tableName,
      where: 'user_id = ? AND is_synced = 0',
      whereArgs: [userId],
    );
    return results.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Mark transactions as synced
  static Future<void> markAsSynced(List<String> ids) async {
    final db = await DatabaseService.database;
    for (final id in ids) {
      await db.update(
        _tableName,
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}
