/// Yearly Summary Domain Entity
/// 
/// Represents aggregated yearly expense data in the domain layer.
/// Provides comprehensive annual analytics including monthly breakdowns,
/// category analysis, and trend calculations.
/// 
/// Key Features:
/// - Annual expense aggregation
/// - Monthly distribution analysis
/// - Category-wise yearly breakdown
/// - Trend analysis and insights
/// - Statistical summaries
/// - Framework-agnostic design
/// 
/// Business Rules:
/// - Each summary represents exactly one calendar year
/// - Monthly totals must sum to total amount
/// - Category totals must sum to total amount
/// - Active months count only months with expenses > 0

import 'package:equatable/equatable.dart';

/// Domain entity representing yearly expense summary
/// 
/// Aggregates and analyzes expense data for an entire year,
/// providing comprehensive insights and trends.
class YearlySummary extends Equatable {
  /// The year this summary represents
  final int year;

  /// Total amount spent in this year
  final double totalAmount;

  /// Category-wise breakdown for the entire year
  final Map<String, double> categoryTotals;

  /// Monthly totals for this year (month 1-12)
  final Map<int, double> monthlyTotals;

  /// Total number of transactions in this year
  final int totalTransactions;

  /// Number of active months (months with expenses)
  final int activeMonths;

  /// Highest spending month (1-12)
  final int? highestSpendingMonth;

  /// Lowest spending month (1-12, excluding zero months)
  final int? lowestSpendingMonth;

  /// Date when this summary was last updated
  final DateTime lastUpdated;

  const YearlySummary({
    required this.year,
    required this.totalAmount,
    required this.categoryTotals,
    required this.monthlyTotals,
    required this.totalTransactions,
    required this.activeMonths,
    this.highestSpendingMonth,
    this.lowestSpendingMonth,
    required this.lastUpdated,
  });

  /// Gets the average monthly spending for this year
  /// 
  /// Returns average based on active months only
  double get averageMonthlySpending {
    return activeMonths > 0 ? totalAmount / activeMonths : 0.0;
  }

  /// Gets the average transaction amount for this year
  /// 
  /// Returns average amount per transaction
  double get averageTransactionAmount {
    return totalTransactions > 0 ? totalAmount / totalTransactions : 0.0;
  }

  /// Gets the top spending category for this year
  /// 
  /// Returns the category with highest spending or null if no expenses
  String? get topCategory {
    if (categoryTotals.isEmpty) return null;
    return categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Gets the percentage of year completed with expenses
  /// 
  /// Returns percentage of months that have expenses (0-100)
  double get yearCompletionPercentage {
    return (activeMonths / 12) * 100;
  }

  /// Gets spending trend for the year (increasing/decreasing)
  /// 
  /// Compares first half vs second half of the year
  /// Returns positive for increasing trend, negative for decreasing
  double get spendingTrend {
    double firstHalf = 0;
    double secondHalf = 0;

    for (int month = 1; month <= 6; month++) {
      firstHalf += monthlyTotals[month] ?? 0;
    }
    for (int month = 7; month <= 12; month++) {
      secondHalf += monthlyTotals[month] ?? 0;
    }

    if (firstHalf == 0) return secondHalf > 0 ? 1.0 : 0.0;
    return (secondHalf - firstHalf) / firstHalf;
  }

  /// Gets the name of the highest spending month
  /// 
  /// Returns month name or null if no expenses
  String? get highestSpendingMonthName {
    if (highestSpendingMonth == null) return null;
    return _getMonthName(highestSpendingMonth!);
  }

  /// Gets the name of the lowest spending month
  /// 
  /// Returns month name or null if no expenses
  String? get lowestSpendingMonthName {
    if (lowestSpendingMonth == null) return null;
    return _getMonthName(lowestSpendingMonth!);
  }

  /// Gets spending for a specific month
  /// 
  /// [month] Month number (1-12)
  /// Returns spending amount for the specified month
  double getMonthlySpending(int month) {
    return monthlyTotals[month] ?? 0.0;
  }

  /// Gets spending for a specific category
  /// 
  /// [category] Category name
  /// Returns total spending for the specified category
  double getCategorySpending(String category) {
    return categoryTotals[category] ?? 0.0;
  }

  /// Gets the list of all categories with spending
  /// 
  /// Returns sorted list of category names (highest spending first)
  List<String> get categoriesOrderedBySpending {
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList();
  }

  /// Gets the list of active months (months with expenses)
  /// 
  /// Returns list of month numbers that have expenses > 0
  List<int> get activeMonthsList {
    return monthlyTotals.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList()
      ..sort();
  }

  /// Checks if this year has any expenses
  /// 
  /// Returns true if there are any expenses in this year
  bool get hasExpenses {
    return totalAmount > 0;
  }

  /// Gets the spending variance (how much spending varies month to month)
  /// 
  /// Returns standard deviation of monthly spending amounts
  double get monthlySpendingVariance {
    if (activeMonths <= 1) return 0.0;

    final activeAmounts = monthlyTotals.values.where((amount) => amount > 0).toList();
    final mean = totalAmount / activeMonths;
    
    double sumSquaredDifferences = 0;
    for (final amount in activeAmounts) {
      final difference = amount - mean;
      sumSquaredDifferences += difference * difference;
    }
    
    return sumSquaredDifferences / activeMonths;
  }

  /// Gets spending consistency score (0-100, higher is more consistent)
  /// 
  /// Returns a score indicating how consistent monthly spending is
  double get spendingConsistencyScore {
    if (activeMonths <= 1) return 100.0;
    
    final variance = monthlySpendingVariance;
    final mean = averageMonthlySpending;
    
    if (mean == 0) return 100.0;
    
    final coefficientOfVariation = (variance / (mean * mean));
    return (100.0 / (1.0 + coefficientOfVariation)).clamp(0.0, 100.0);
  }

  /// Helper method to get month name from number
  String _getMonthName(int month) {
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month];
  }

  @override
  List<Object?> get props => [
    year,
    totalAmount,
    categoryTotals,
    monthlyTotals,
    totalTransactions,
    activeMonths,
    highestSpendingMonth,
    lowestSpendingMonth,
    lastUpdated,
  ];

  /// Creates a copy of this summary with updated values
  /// 
  /// Allows for immutable updates while preserving other properties
  YearlySummary copyWith({
    int? year,
    double? totalAmount,
    Map<String, double>? categoryTotals,
    Map<int, double>? monthlyTotals,
    int? totalTransactions,
    int? activeMonths,
    int? highestSpendingMonth,
    int? lowestSpendingMonth,
    DateTime? lastUpdated,
  }) {
    return YearlySummary(
      year: year ?? this.year,
      totalAmount: totalAmount ?? this.totalAmount,
      categoryTotals: categoryTotals ?? this.categoryTotals,
      monthlyTotals: monthlyTotals ?? this.monthlyTotals,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      activeMonths: activeMonths ?? this.activeMonths,
      highestSpendingMonth: highestSpendingMonth ?? this.highestSpendingMonth,
      lowestSpendingMonth: lowestSpendingMonth ?? this.lowestSpendingMonth,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}