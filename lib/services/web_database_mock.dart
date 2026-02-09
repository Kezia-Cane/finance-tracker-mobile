import 'dart:async';
import 'package:sqflite_common/sqlite_api.dart';

/// A simplified in-memory mock of the SQLite Database for Web/Chrome support.
/// This avoids the need for sqlite3.wasm binaries during initial development.
class WebDatabaseMock implements Database {
  final Map<String, List<Map<String, Object?>>> _tables = {};
  bool _isOpen = true;

  @override
  String get path => ':memory:';

  @override
  bool get isOpen => _isOpen;

  @override
  Future<void> close() async {
    _isOpen = false;
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    _tables.putIfAbsent(table, () => []);
    _tables[table]!.add(Map.from(values));
    return _tables[table]!.length;
  }

  @override
  Future<List<Map<String, Object?>>> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    var results = _tables[table] ?? [];
    
    // Simple filter for where user_id = ?
    if (where != null && where.contains('user_id = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final userId = whereArgs[0];
      results = results.where((row) => row['user_id'] == userId).toList();
    }

    // Simple sort for date DESC
    if (orderBy != null && orderBy.contains('date DESC')) {
      results.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    }

    if (limit != null) {
      results = results.take(limit).toList();
    }

    return results;
  }

  @override
  Future<int> update(String table, Map<String, Object?> values,
      {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) async {
    var results = _tables[table] ?? [];
    int count = 0;
    
    if (where != null && where.contains('id = ?') && whereArgs != null) {
      final id = whereArgs[0];
      for (var i = 0; i < results.length; i++) {
        if (results[i]['id'] == id) {
          results[i] = {...results[i], ...values};
          count++;
        }
      }
    }
    return count;
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    if (where != null && where.contains('id = ?') && whereArgs != null) {
      final id = whereArgs[0];
      final initialLength = _tables[table]?.length ?? 0;
      _tables[table]?.removeWhere((row) => row['id'] == id);
      return initialLength - (_tables[table]?.length ?? 0);
    }
    if (where == null) {
      final count = _tables[table]?.length ?? 0;
      _tables[table] = [];
      return count;
    }
    return 0;
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    // Basic support for aggregation queries used in TransactionService
    if (sql.contains('SUM(amount)') && sql.contains('is_expense = 0')) {
      final userId = arguments?[0];
      final total = (_tables['transactions'] ?? [])
          .where((row) => row['user_id'] == userId && row['is_expense'] == 0)
          .fold(0.0, (sum, row) => sum + (row['amount'] as num).toDouble());
      return [{'total': total}];
    }
    if (sql.contains('SUM(amount)') && sql.contains('is_expense = 1')) {
      final userId = arguments?[0];
      final total = (_tables['transactions'] ?? [])
          .where((row) => row['user_id'] == userId && row['is_expense'] == 1)
          .fold(0.0, (sum, row) => sum + (row['amount'] as num).toDouble());
      return [{'total': total}];
    }
    return [];
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    // Table creation is skipped in mock
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action, {bool? exclusive}) async {
    // Transactions not supported in simple mock
    return action(null as dynamic);
  }

  @override
  Batch batch() => null as dynamic;

  @override
  Future<int> getVersion() async => 0;

  @override
  Future<void> setVersion(int version) async {}

  @override
  // ignore: unnecessary_overrides
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
