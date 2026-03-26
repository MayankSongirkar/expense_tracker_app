// Monthly Archive Model for Expense History
// 
// Stores archived expenses for each month to enable monthly reset functionality
// while preserving historical data for analytics and reporting. Also tracks
// yearly totals for comprehensive expense analysis.
// 
// Key Features:
// - Monthly grouping of expenses with reset capability
// - Yearly total tracking and aggregation
// - Efficient storage and retrieval by month/year
// - Maintains expense history for analytics
// - Supports monthly reset workflow
// - Category-wise breakdown for detailed analysis
// 
// Architecture:
// - Uses Hive for local persistence
// - Separate storage from current expenses
// - Indexed by year-month for fast access
// - Yearly summaries for long-term trends

import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';
import 'expense_model.dart';

part 'monthly_archive_model.g.dart';

/// Hive model for monthly expense archives
@HiveType(typeId: 1)
class MonthlyArchiveModel extends HiveObject {
  /// Year-month key in format "YYYY-MM" (e.g., "2024-03")
  @HiveField(0)
  final String monthKey;

  /// Year of the archived month
  @HiveField(1)
  final int year;

  /// Month of the archived month (1-12)
  @HiveField(2)
  final int month;

  /// List of expenses for this month
  @HiveField(3)
  final List<ExpenseModel> expenses;

  /// Total amount spent in this month
  @HiveField(4)
  final double totalAmount;

  /// Date when this archive was created
  @HiveField(5)
  final DateTime archivedDate;

  /// Category-wise breakdown of expenses for this month
  @HiveField(6)
  final Map<String, double> categoryTotals;

  /// Number of transactions in this month
  @HiveField(7)
  final int transactionCount;

  MonthlyArchiveModel({
    required this.monthKey,
    required this.year,
    required this.month,
    required this.expenses,
    required this.totalAmount,
    required this.archivedDate,
    required this.categoryTotals,
    required this.transactionCount,
  });

  /// Creates archive from a list of expenses for a specific month
  /// 
  /// [year] The year of the month to archive
  /// [month] The month to archive (1-12)
  /// [expenses] List of expenses to archive
  /// 
  /// Returns a new MonthlyArchiveModel with calculated totals and breakdowns
  factory MonthlyArchiveModel.fromExpenses({
    required int year,
    required int month,
    required List<Expense> expenses,
  }) {
    final monthKey = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
    final expenseModels = expenses.map((e) => ExpenseModel.fromEntity(e)).toList();
    final totalAmount = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    
    // Calculate category-wise totals
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return MonthlyArchiveModel(
      monthKey: monthKey,
      year: year,
      month: month,
      expenses: expenseModels,
      totalAmount: totalAmount,
      archivedDate: DateTime.now(),
      categoryTotals: categoryTotals,
      transactionCount: expenses.length,
    );
  }

  /// Converts archived expenses back to domain entities
  /// 
  /// Returns list of expense entities from this archive
  List<Expense> toExpenseEntities() {
    return expenses.map((model) => model.toEntity()).toList();
  }

  /// Gets the month name for display purposes
  /// 
  /// Returns formatted month name (e.g., "March 2024")
  String get displayName {
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[month]} $year';
  }

  /// Gets the short month name for compact display
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

  /// Gets average expense amount for this month
  /// 
  /// Returns average amount per transaction
  double get averageExpense {
    return transactionCount > 0 ? totalAmount / transactionCount : 0.0;
  }

  /// Converts to JSON for export or backup
  Map<String, dynamic> toJson() {
    return {
      'monthKey': monthKey,
      'year': year,
      'month': month,
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'archivedDate': archivedDate.toIso8601String(),
      'categoryTotals': categoryTotals,
      'transactionCount': transactionCount,
    };
  }

  /// Creates from JSON for import or restore
  factory MonthlyArchiveModel.fromJson(Map<String, dynamic> json) {
    return MonthlyArchiveModel(
      monthKey: json['monthKey'],
      year: json['year'],
      month: json['month'],
      expenses: (json['expenses'] as List)
          .map((e) => ExpenseModel.fromJson(e))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      archivedDate: DateTime.parse(json['archivedDate']),
      categoryTotals: Map<String, double>.from(json['categoryTotals'] ?? {}),
      transactionCount: json['transactionCount'] ?? 0,
    );
  }
}