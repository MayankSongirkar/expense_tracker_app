/// Expense Archive Data Source
/// 
/// Handles local storage operations for monthly archives and yearly summaries.
/// Provides efficient storage and retrieval of historical expense data with
/// support for monthly reset functionality and comprehensive analytics.
/// 
/// Key Responsibilities:
/// - Monthly archive storage and retrieval
/// - Yearly summary calculation and caching
/// - Monthly reset operations
/// - Historical data access for analytics
/// - Data integrity and consistency management
/// 
/// Architecture:
/// - Uses separate Hive boxes for archives and summaries
/// - Efficient indexing by month/year keys
/// - Automatic yearly summary updates
/// - Optimized for analytics queries

import 'package:hive/hive.dart';
import '../models/monthly_archive_model.dart';
import '../models/yearly_summary_model.dart';

/// Abstract interface for expense archive operations
abstract class ExpenseArchiveDataSource {
  // Monthly Archive Operations
  Future<void> archiveMonth(MonthlyArchiveModel archive);
  Future<MonthlyArchiveModel?> getMonthlyArchive(int year, int month);
  Future<List<MonthlyArchiveModel>> getYearlyArchives(int year);
  Future<List<MonthlyArchiveModel>> getAllArchives();
  Future<void> deleteMonthlyArchive(int year, int month);

  // Yearly Summary Operations
  Future<void> updateYearlySummary(YearlySummaryModel summary);
  Future<YearlySummaryModel?> getYearlySummary(int year);
  Future<List<YearlySummaryModel>> getAllYearlySummaries();
  Future<void> deleteYearlySummary(int year);

  // Utility Operations
  Future<bool> hasArchiveForMonth(int year, int month);
  Future<List<int>> getAvailableYears();
  Future<void> clearAllArchives();
}

/// Implementation of expense archive data source using Hive
class ExpenseArchiveDataSourceImpl implements ExpenseArchiveDataSource {
  /// Hive box for monthly archives
  final Box<MonthlyArchiveModel> archiveBox;
  
  /// Hive box for yearly summaries
  final Box<YearlySummaryModel> summaryBox;

  ExpenseArchiveDataSourceImpl({
    required this.archiveBox,
    required this.summaryBox,
  });

  // ==================== MONTHLY ARCHIVE OPERATIONS ====================

  @override
  Future<void> archiveMonth(MonthlyArchiveModel archive) async {
    await archiveBox.put(archive.monthKey, archive);
    
    // Update yearly summary after archiving
    await _updateYearlySummaryForYear(archive.year);
  }

  @override
  Future<MonthlyArchiveModel?> getMonthlyArchive(int year, int month) async {
    final monthKey = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
    return archiveBox.get(monthKey);
  }

  @override
  Future<List<MonthlyArchiveModel>> getYearlyArchives(int year) async {
    final archives = <MonthlyArchiveModel>[];
    
    for (int month = 1; month <= 12; month++) {
      final archive = await getMonthlyArchive(year, month);
      if (archive != null) {
        archives.add(archive);
      }
    }
    
    // Sort by month
    archives.sort((a, b) => a.month.compareTo(b.month));
    return archives;
  }

  @override
  Future<List<MonthlyArchiveModel>> getAllArchives() async {
    final archives = archiveBox.values.toList();
    
    // Sort by year and month (newest first)
    archives.sort((a, b) {
      final yearComparison = b.year.compareTo(a.year);
      if (yearComparison != 0) return yearComparison;
      return b.month.compareTo(a.month);
    });
    
    return archives;
  }

  @override
  Future<void> deleteMonthlyArchive(int year, int month) async {
    final monthKey = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
    await archiveBox.delete(monthKey);
    
    // Update yearly summary after deletion
    await _updateYearlySummaryForYear(year);
  }

  // ==================== YEARLY SUMMARY OPERATIONS ====================

  @override
  Future<void> updateYearlySummary(YearlySummaryModel summary) async {
    await summaryBox.put(summary.year, summary);
  }

  @override
  Future<YearlySummaryModel?> getYearlySummary(int year) async {
    return summaryBox.get(year);
  }

  @override
  Future<List<YearlySummaryModel>> getAllYearlySummaries() async {
    final summaries = summaryBox.values.toList();
    
    // Sort by year (newest first)
    summaries.sort((a, b) => b.year.compareTo(a.year));
    return summaries;
  }

  @override
  Future<void> deleteYearlySummary(int year) async {
    await summaryBox.delete(year);
  }

  // ==================== UTILITY OPERATIONS ====================

  @override
  Future<bool> hasArchiveForMonth(int year, int month) async {
    final archive = await getMonthlyArchive(year, month);
    return archive != null;
  }

  @override
  Future<List<int>> getAvailableYears() async {
    final years = <int>{};
    
    // Get years from archives
    for (final archive in archiveBox.values) {
      years.add(archive.year);
    }
    
    // Get years from summaries
    for (final summary in summaryBox.values) {
      years.add(summary.year);
    }
    
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    return sortedYears;
  }

  @override
  Future<void> clearAllArchives() async {
    await archiveBox.clear();
    await summaryBox.clear();
  }

  // ==================== PRIVATE HELPER METHODS ====================

  /// Updates the yearly summary for a specific year
  /// 
  /// Recalculates the yearly summary based on all monthly archives
  /// for the given year and stores the updated summary.
  /// 
  /// [year] The year to update the summary for
  Future<void> _updateYearlySummaryForYear(int year) async {
    final yearlyArchives = await getYearlyArchives(year);
    
    if (yearlyArchives.isEmpty) {
      // No archives for this year, delete summary if it exists
      await deleteYearlySummary(year);
      return;
    }
    
    // Create updated yearly summary
    final summary = YearlySummaryModel.fromMonthlyArchives(
      year: year,
      monthlyArchives: yearlyArchives,
    );
    
    await updateYearlySummary(summary);
  }

  /// Gets statistics for debugging and monitoring
  /// 
  /// Returns a map with useful statistics about the archive storage
  Future<Map<String, dynamic>> getStorageStatistics() async {
    final totalArchives = archiveBox.length;
    final totalSummaries = summaryBox.length;
    final availableYears = await getAvailableYears();
    
    double totalArchivedAmount = 0;
    int totalArchivedTransactions = 0;
    
    for (final archive in archiveBox.values) {
      totalArchivedAmount += archive.totalAmount;
      totalArchivedTransactions += archive.transactionCount;
    }
    
    return {
      'totalArchives': totalArchives,
      'totalSummaries': totalSummaries,
      'availableYears': availableYears,
      'totalArchivedAmount': totalArchivedAmount,
      'totalArchivedTransactions': totalArchivedTransactions,
      'oldestYear': availableYears.isNotEmpty ? availableYears.last : null,
      'newestYear': availableYears.isNotEmpty ? availableYears.first : null,
    };
  }
}