import 'package:equatable/equatable.dart';

/// Expense entity representing a single expense record
class Expense extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  @override
  List<Object?> get props => [id, title, amount, category, date, notes];

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
