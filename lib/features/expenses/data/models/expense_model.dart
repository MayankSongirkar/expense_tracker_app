import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

/// Hive model for expense persistence
@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? notes;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  /// Convert to domain entity
  Expense toEntity() {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      category: category,
      date: date,
      notes: notes,
    );
  }

  /// Create from domain entity
  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      notes: expense.notes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  /// Create from JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }
}
