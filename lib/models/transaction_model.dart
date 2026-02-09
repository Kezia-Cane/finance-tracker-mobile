/// TransactionModel - Data model for financial transactions
/// 
/// Represents a single income or expense transaction with all
/// necessary metadata for display and synchronization.
class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final String? notes;
  final DateTime date;
  final bool isExpense;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    this.notes,
    required this.date,
    required this.isExpense,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from database map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      notes: map['notes'] as String?,
      date: DateTime.parse(map['date'] as String),
      isExpense: (map['is_expense'] as int) == 1,
      isSynced: (map['is_synced'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'notes': notes,
      'date': date.toIso8601String(),
      'is_expense': isExpense ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    String? category,
    String? notes,
    DateTime? date,
    bool? isExpense,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get the display amount (negative for expenses)
  double get displayAmount => isExpense ? -amount : amount;

  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $displayAmount, category: $category)';
  }
}
