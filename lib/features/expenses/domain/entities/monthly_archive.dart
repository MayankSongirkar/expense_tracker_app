// Monthly Archive Domain Entity
// 
// Represents a monthly archive of expenses in the domain layer.
// Contains aggregated expense data for a specific month with
// comprehensive analytics and summary information.
// 
// Key Features:
// - Monthly expense aggregation
// - Category-wise breakdown
// - Statistical summaries
// - Framework-agnostic design
// - Immutable data structure
// 
// Business Rules:
// - Each archive represents exactly one calendar month
// - Archives are immutable once created
// - Category totals must sum to total amount
// - Transaction count must match expense list length

import 'package:equatable/equatable.dart';
import 'expense.dart';

/// Domain entity representing a monthly expense archive
/// 
/// Contains all expenses for a specific month along with
/// calculated summaries and analytics data.
class MonthlyArchive extends Equatable {
  /// Unique identifier for the month (YYYY-MM format)
  final String monthKey;

  /// Year of the archived month
  final int year;

  /// Month of the archived month (1-12)
  final int month;

  /// List of expenses in this archive
  final List<Expense> expenses;

  /// Total amount spent in this month
  final double totalAmount;

  /// Date when this archive was created
  final DateTime archivedDate;

  /// Category-wise breakdown of expenses
  final Map<String, double> categoryTotals;

  /// Number of transactions in this month
  final int transactionCount;

  const MonthlyArchive({
    required this.monthKey,
    required this.year,
    required this.month,
    required this.expenses,
    required this.totalAmount,
    required this.archivedDate,
    required this.categoryTotals,
    required this.transactionCount,
  });

  /// Creates a monthly archive from a list of expenses
  /// 
  /// [year] The year of the month to archive
  /// [month] The month to archive (1-12)
  /// [expenses] List of expenses to include in the archive
  /// 
  /// Returns a new MonthlyArchive with calculated totals
  factory MonthlyArchive.fromExpenses({
    required int year,
    required int month,
    required List<Expense> expenses,
  }) {
    final monthKey = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
    final totalAmount = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    
    // Calculate category totals
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return MonthlyArchive(
      monthKey: monthKey,
      year: year,
      month: month,
      expenses: expenses,
      totalAmount: totalAmount,
      archivedDate: DateTime.now(),
      categoryTotals: categoryTotals,
      transactionCount: expenses.length,
    );
  }

  /// Gets the display name for this month
  /// 
  /// Returns formatted month name (e.g., "March 2024")
  String get displayName {
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[month]} $year';
  }

  /// Gets the short display name for this month
  /// 
  /// Returns abbreviated month name (e.g., "Mar 2024")
  String get shortDisplayName {
    final shortMonthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${shortMonthNames[month]} $year';
  }

  /// Gets the top spending category for this month
  /// 
  /// Returns the category with highest spending or null if no expenses
  String? get topCategory {
    if (categoryTotals.isEmpty) return null;
    return categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Gets the average expense amount for this month
  /// 
  /// Returns average amount per transaction
  double get averageExpense {
    return transactionCount > 0 ? totalAmount / transactionCount : 0.0;
  }

  /// Gets expenses for a specific category
  /// 
  /// [category] The category to filter by
  /// Returns list of expenses in the specified category
  List<Expense> getExpensesByCategory(String category) {
    return expenses.where((expense) => expense.category == category).toList();
  }

  /// Gets the number of unique categories in this month
  /// 
  /// Returns count of different expense categories
  int get categoryCount {
    return categoryTotals.keys.length;
  }

  /// Checks if this archive has expenses
  /// 
  /// Returns true if there are any expenses in this archive
  bool get hasExpenses {
    return expenses.isNotEmpty;
  }

  /// Gets the date range covered by this archive
  /// 
  /// Returns a tuple of (earliest date, latest date) from expenses
  (DateTime?, DateTime?) get dateRange {
    if (expenses.isEmpty) return (null, null);
    
    DateTime earliest = expenses.first.date;
    DateTime latest = expenses.first.date;
    
    for (final expense in expenses) {
      if (expense.date.isBefore(earliest)) earliest = expense.date;
      if (expense.date.isAfter(latest)) latest = expense.date;
    }
    
    return (earliest, latest);
  }

  @override
  List<Object?> get props => [
    monthKey,
    year,
    month,
    expenses,
    totalAmount,
    archivedDate,
    categoryTotals,
    transactionCount,
  ];

  /// Creates a copy of this archive with updated values
  /// 
  /// Allows for immutable updates while preserving other properties
  MonthlyArchive copyWith({
    String? monthKey,
    int? year,
    int? month,
    List<Expense>? expenses,
    double? totalAmount,
    DateTime? archivedDate,
    Map<String, double>? categoryTotals,
    int? transactionCount,
  }) {
    return MonthlyArchive(
      monthKey: monthKey ?? this.monthKey,
      year: year ?? this.year,
      month: month ?? this.month,
      expenses: expenses ?? this.expenses,
      totalAmount: totalAmount ?? this.totalAmount,
      archivedDate: archivedDate ?? this.archivedDate,
      categoryTotals: categoryTotals ?? this.categoryTotals,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }
}