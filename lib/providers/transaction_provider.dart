import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

/// TransactionProvider - State management for transactions
/// 
/// Manages the transaction list in memory and syncs with SQLite.
/// Provides reactive updates to the UI when data changes.
class TransactionProvider with ChangeNotifier {
  /// Local mock user ID for offline-first mode
  static const String localUserId = 'local_user_001';

  List<TransactionModel> _transactions = [];
  double _totalBalance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  double get totalBalance => _totalBalance;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get recent transactions (last 5)
  List<TransactionModel> get recentTransactions =>
      _transactions.take(5).toList();

  /// Initialize and load all transactions from local database
  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await TransactionService.getAll(localUserId);
      await _loadTotals();
    } catch (e) {
      _error = 'Failed to load transactions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load totals from database
  Future<void> _loadTotals() async {
    _totalBalance = await TransactionService.getTotalBalance(localUserId);
    _totalIncome = await TransactionService.getTotalIncome(localUserId);
    _totalExpense = await TransactionService.getTotalExpense(localUserId);
  }

  /// Add a new transaction
  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    String? notes,
    required DateTime date,
    required bool isExpense,
  }) async {
    try {
      final transaction = await TransactionService.create(
        userId: localUserId,
        title: title,
        amount: amount,
        category: category,
        notes: notes,
        date: date,
        isExpense: isExpense,
      );

      // Add to local list and update totals
      _transactions.insert(0, transaction);
      await _loadTotals();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add transaction: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final updated = await TransactionService.update(transaction);

      // Replace in local list
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = updated;
      }
      await _loadTotals();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update transaction: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await TransactionService.delete(id);

      // Remove from local list
      _transactions.removeWhere((t) => t.id == id);
      await _loadTotals();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete transaction: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Filter transactions by type
  List<TransactionModel> filterByType(String type) {
    if (type == 'All') return _transactions;
    if (type == 'Income') return _transactions.where((t) => !t.isExpense).toList();
    if (type == 'Expense') return _transactions.where((t) => t.isExpense).toList();
    return _transactions;
  }

  /// Search transactions by title or category
  List<TransactionModel> search(String query) {
    if (query.isEmpty) return _transactions;
    final lowerQuery = query.toLowerCase();
    return _transactions.where((t) =>
        t.title.toLowerCase().contains(lowerQuery) ||
        t.category.toLowerCase().contains(lowerQuery)).toList();
  }

  /// Clear any error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
