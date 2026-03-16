/// Yearly Summary Model for Annual Expense Tracking
/// 
/// Aggregates and stores yearly expense data for comprehensive annual analysis.
/// Provides yearly totals, category breakdowns, and trend analysis capabilities.
/// 
/// Key Features:
/// - Annual expense aggregation from monthly archives
/// - Category-wise yearly breakdown
/// - Monthly distribution within the year
/// - Year-over-year comparison support
/// - Efficient yearly analytics and reporting
/// 
/// Architecture:
/// - Uses Hive for local persistence
/// - Automatically updated when monthly archives are created
/// - Indexed by year for fast access
/// - Supports multi-year trend analysis

import 'package:hive/hive.dart';
import 'monthly_archive_model.dart';

part 'yearly_summary_model.g.dart';

/// Hive model for yearly expense summaries
@HiveType(typeId: 2)
class YearlySummaryModel extends HiveObject {
  /// The year this summary represents
  @HiveField(0)
  final int year;

  /// Total amount spent in this year
  @HiveField(1)
  final double totalAmount;

  /// Category-wise breakdown for the entire year
  @HiveField(2)
  final Map<String, double> categoryTotals;

  /// Monthly totals for this year (month 1-12)
  @HiveField(3)
  final Map<int, double> monthlyTotals;

  /// Total number of transactions in this year
  @HiveField(4)
  final int totalTransactions;

  /// Number of active months (months with expenses)
  @HiveField(5)
  final int activeMonths;

  /// Highest spending month (1-12)
  @HiveField(6)
  final int? highestSpendingMonth;

  /// Lowest spending month (1-12, excluding zero months)
  @HiveField(7)
  final int? lowestSpendingMonth;

  /// Date when this summary was last updated
  @HiveField(8)
  final DateTime lastUpdated;

  YearlySummaryModel({
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

  /// Creates yearly summary from monthly archives
  /// 
  /// [year] The year to summarize
  /// [monthlyArchives] List of monthly archives for this year
  /// 
  /// Returns a comprehensive yearly summary with all calculations
  factory YearlySummaryModel.fromMonthlyArchives({
    required int year,
    required List<MonthlyArchiveModel> monthlyArchives,
  }) {
    double totalAmount = 0;
    int totalTransactions = 0;
    final categoryTotals = <String, double>{};
    final monthlyTotals = <int, double>{};
    
    // Initialize all months to 0
    for (int month = 1; month <= 12; month++) {
      monthlyTotals[month] = 0;
    }

    // Process each monthly archive
    for (final archive in monthlyArchives) {
      if (archive.year == year) {
        totalAmount += archive.totalAmount;
        totalTransactions += archive.transactionCount;
        monthlyTotals[archive.month] = archive.totalAmount;

        // Aggregate category totals
        archive.categoryTotals.forEach((category, amount) {
          categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        });
      }
    }

    // Calculate active months (months with expenses > 0)
    final activeMonths = monthlyTotals.values.where((amount) => amount > 0).length;

    // Find highest and lowest spending months
    int? highestMonth;
    int? lowestMonth;
    double highestAmount = 0;
    double lowestAmount = double.infinity;

    monthlyTotals.forEach((month, amount) {
      if (amount > 0) {
        if (amount > highestAmount) {
          highestAmount = amount;
          highestMonth = month;
        }
        if (amount < lowestAmount) {
          lowestAmount = amount;
          lowestMonth = month;
        }
      }
    });

    return YearlySummaryModel(
      year: year,
      totalAmount: totalAmount,
      categoryTotals: categoryTotals,
      monthlyTotals: monthlyTotals,
      totalTransactions: totalTransactions,
      activeMonths: activeMonths,
      highestSpendingMonth: highestMonth,
      lowestSpendingMonth: lowestMonth,
      lastUpdated: DateTime.now(),
    );
  }

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
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[highestSpendingMonth!];
  }

  /// Gets the name of the lowest spending month
  /// 
  /// Returns month name or null if no expenses
  String? get lowestSpendingMonthName {
    if (lowestSpendingMonth == null) return null;
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[lowestSpendingMonth!];
  }

  /// Converts to JSON for export or backup
  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'totalAmount': totalAmount,
      'categoryTotals': categoryTotals,
      'monthlyTotals': monthlyTotals.map((k, v) => MapEntry(k.toString(), v)),
      'totalTransactions': totalTransactions,
      'activeMonths': activeMonths,
      'highestSpendingMonth': highestSpendingMonth,
      'lowestSpendingMonth': lowestSpendingMonth,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Creates from JSON for import or restore
  factory YearlySummaryModel.fromJson(Map<String, dynamic> json) {
    final monthlyTotalsMap = <int, double>{};
    (json['monthlyTotals'] as Map<String, dynamic>).forEach((k, v) {
      monthlyTotalsMap[int.parse(k)] = v.toDouble();
    });

    return YearlySummaryModel(
      year: json['year'],
      totalAmount: json['totalAmount'].toDouble(),
      categoryTotals: Map<String, double>.from(json['categoryTotals']),
      monthlyTotals: monthlyTotalsMap,
      totalTransactions: json['totalTransactions'],
      activeMonths: json['activeMonths'],
      highestSpendingMonth: json['highestSpendingMonth'],
      lowestSpendingMonth: json['lowestSpendingMonth'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}