/// Domain Entity: Expense
/// 
/// Core business entity representing a single expense record in the system.
/// This entity follows Domain-Driven Design principles and is framework-agnostic.
/// 
/// Key Features:
/// - Immutable data structure using Equatable for value equality
/// - Required fields validation through constructor
/// - Copy method for creating modified instances
/// - Clean separation from data models and UI representations
/// 
/// Business Rules:
/// - Each expense must have a unique identifier
/// - Amount must be a positive number (validated at use case level)
/// - Date represents when the expense occurred
/// - Category helps in expense classification and analytics
/// - Notes are optional for additional context

import 'package:equatable/equatable.dart';

/// Expense domain entity
/// 
/// Represents a single expense transaction with all necessary business data.
/// Extends Equatable for value-based equality comparison, which is essential
/// for state management and testing.
/// 
/// Properties:
/// - [id]: Unique identifier for the expense (UUID recommended)
/// - [title]: Human-readable description of the expense
/// - [amount]: Monetary value in Indian Rupees (₹)
/// - [category]: Classification category (Food, Travel, Shopping, etc.)
/// - [date]: When the expense occurred
/// - [notes]: Optional additional details or context
class Expense extends Equatable {
  /// Unique identifier for this expense
  /// 
  /// Should be a UUID or similar unique string to ensure no conflicts
  /// across different devices or data sources.
  final String id;

  /// Title or description of the expense
  /// 
  /// Should be descriptive enough for the user to understand
  /// what this expense was for (e.g., "Lunch at Restaurant", "Uber ride").
  final String title;

  /// Amount spent in Indian Rupees
  /// 
  /// Always stored as a positive double value. The currency formatting
  /// and display is handled at the presentation layer.
  final double amount;

  /// Category classification for the expense
  /// 
  /// Used for analytics, filtering, and budgeting. Common categories
  /// include: Food, Travel, Shopping, Bills, Entertainment, Other.
  final String category;

  /// Date when the expense occurred
  /// 
  /// Used for chronological sorting, monthly analytics, and date-based
  /// filtering. Should represent the actual expense date, not creation date.
  final DateTime date;

  /// Optional additional notes or context
  /// 
  /// Can include details like location, people involved, or any other
  /// relevant information the user wants to remember.
  final String? notes;

  /// Creates a new Expense instance
  /// 
  /// All parameters except [notes] are required. The [amount] should be
  /// positive, and [id] should be unique across all expenses.
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  /// Properties used for equality comparison
  /// 
  /// Equatable uses this list to determine if two Expense instances
  /// are equal based on their values rather than reference.
  @override
  List<Object?> get props => [id, title, amount, category, date, notes];

  /// Creates a copy of this expense with optionally updated values
  /// 
  /// This method enables immutable updates by creating a new instance
  /// with modified properties while keeping others unchanged.
  /// 
  /// Example:
  /// ```dart
  /// final updatedExpense = expense.copyWith(
  ///   amount: 150.0,
  ///   notes: 'Updated notes',
  /// );
  /// ```
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
