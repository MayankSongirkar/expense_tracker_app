/// Use Case: Get Monthly Archives
/// 
/// Domain layer use case for retrieving historical monthly expense archives.
/// Provides various methods to access archived expense data for analytics,
/// reporting, and historical analysis.
/// 
/// Key Responsibilities:
/// - Retrieve monthly archives by various criteria
/// - Provide filtered access to historical data
/// - Support analytics and reporting requirements
/// - Maintain clean interface for presentation layer
/// 
/// Business Rules:
/// - Archives are read-only historical data
/// - Data is returned in consistent, sorted order
/// - Filtering maintains data integrity
/// - Empty results are handled gracefully
/// 
/// Usage:
/// ```dart
/// final getArchives = GetMonthlyArchives(archiveRepository);
/// final archives = await getArchives.forYear(2024);
/// ```

import '../entities/monthly_archive.dart';
import '../entities/yearly_summary.dart';
import '../repositories/expense_archive_repository.dart';

/// Use case for retrieving monthly expense archives
/// 
/// Provides comprehensive access to historical expense data
/// with various filtering and sorting options.
class GetMonthlyArchives {
  /// Repository for archive operations
  final ExpenseArchiveRepository repository;

  /// Creates a GetMonthlyArchives use case with required repository
  /// 
  /// [repository] Repository for archive operations
  GetMonthlyArchives(this.repository);

  /// Retrieves all monthly archives across all years
  /// 
  /// Returns complete list of archives sorted by year and month (newest first).
  /// Useful for comprehensive historical analysis and reporting.
  /// 
  /// Returns:
  /// - [List<MonthlyArchive>] containing all archives
  /// 
  /// Example:
  /// ```dart
  /// final allArchives = await getArchives();
  /// print('Total archived months: ${allArchives.length}');
  /// ```
  Future<List<MonthlyArchive>> call() async {
    return await repository.getAllArchives();
  }

  /// Retrieves monthly archives for a specific year
  /// 
  /// Returns all archives for the specified year, sorted by month.
  /// Useful for yearly analysis and year-over-year comparisons.
  /// 
  /// [year] Year to get archives for
  /// 
  /// Returns:
  /// - [List<MonthlyArchive>] containing archives for the year
  /// 
  /// Example:
  /// ```dart
  /// final yearArchives = await getArchives.forYear(2024);
  /// final totalSpent = yearArchives.fold(0.0, (sum, a) => sum + a.totalAmount);
  /// ```
  Future<List<MonthlyArchive>> forYear(int year) async {
    return await repository.getYearlyArchives(year);
  }

  /// Retrieves a specific monthly archive
  /// 
  /// Returns archive for the specified month and year.
  /// Returns null if no archive exists for that month.
  /// 
  /// [year] Year of the archive
  /// [month] Month of the archive (1-12)
  /// 
  /// Returns:
  /// - [MonthlyArchive?] archive for the month or null if not found
  /// 
  /// Example:
  /// ```dart
  /// final marchArchive = await getArchives.forMonth(2024, 3);
  /// if (marchArchive != null) {
  ///   print('March spending: ${marchArchive.totalAmount}');
  /// }
  /// ```
  Future<MonthlyArchive?> forMonth(int year, int month) async {
    return await repository.getMonthlyArchive(year, month);
  }

  /// Retrieves recent monthly archives
  /// 
  /// Returns the most recent archives up to the specified count.
  /// Useful for trend analysis and recent spending patterns.
  /// 
  /// [count] Number of recent archives to retrieve
  /// 
  /// Returns:
  /// - [List<MonthlyArchive>] containing recent archives (newest first)
  /// 
  /// Example:
  /// ```dart
  /// final recentArchives = await getArchives.recent(6); // Last 6 months
  /// ```
  Future<List<MonthlyArchive>> recent(int count) async {
    final allArchives = await repository.getAllArchives();
    return allArchives.take(count).toList();
  }

  /// Retrieves archives within a date range
  /// 
  /// Returns archives for months that fall within the specified date range.
  /// Useful for custom period analysis and reporting.
  /// 
  /// [startDate] Start of the date range
  /// [endDate] End of the date range
  /// 
  /// Returns:
  /// - [List<MonthlyArchive>] containing archives in the date range
  /// 
  /// Example:
  /// ```dart
  /// final q1Archives = await getArchives.inDateRange(
  ///   DateTime(2024, 1, 1),
  ///   DateTime(2024, 3, 31),
  /// );
  /// ```
  Future<List<MonthlyArchive>> inDateRange(DateTime startDate, DateTime endDate) async {
    final allArchives = await repository.getAllArchives();
    
    return allArchives.where((archive) {
      final archiveDate = DateTime(archive.year, archive.month);
      final rangeStart = DateTime(startDate.year, startDate.month);
      final rangeEnd = DateTime(endDate.year, endDate.month);
      
      return !archiveDate.isBefore(rangeStart) && !archiveDate.isAfter(rangeEnd);
    }).toList();
  }

  /// Retrieves archives with spending above threshold
  /// 
  /// Returns archives where total spending exceeds the specified amount.
  /// Useful for identifying high-spending months.
  /// 
  /// [threshold] Minimum spending amount
  /// 
  /// Returns:
  /// - [List<MonthlyArchive>] containing high-spending archives
  /// 
  /// Example:
  /// ```dart
  /// final highSpendingMonths = await getArchives.withSpendingAbove(50000);
  /// ```
  Future<List<MonthlyArchive>> withSpendingAbove(double threshold) async {
    final allArchives = await repository.getAllArchives();
    return allArchives.where((archive) => archive.totalAmount > threshold).toList();
  }

  /// Retrieves archives for a specific category
  /// 
  /// Returns archives that have expenses in the specified category.
  /// Useful for category-specific analysis.
  /// 
  /// [category] Category to filter by
  /// 
  /// Returns:
  /// - [List<MonthlyArchive>] containing archives with the category
  /// 
  /// Example:
  /// ```dart
  /// final foodMonths = await getArchives.withCategory('Food');
  /// ```
  Future<List<MonthlyArchive>> withCategory(String category) async {
    final allArchives = await repository.getAllArchives();
    return allArchives.where((archive) => 
        archive.categoryTotals.containsKey(category)).toList();
  }

  /// Gets yearly summary for a specific year
  /// 
  /// Returns aggregated yearly data including monthly breakdowns
  /// and category analysis.
  /// 
  /// [year] Year to get summary for
  /// 
  /// Returns:
  /// - [YearlySummary?] yearly summary or null if not found
  /// 
  /// Example:
  /// ```dart
  /// final summary = await getArchives.getYearlySummary(2024);
  /// if (summary != null) {
  ///   print('Year total: ${summary.totalAmount}');
  ///   print('Average monthly: ${summary.averageMonthlySpending}');
  /// }
  /// ```
  Future<YearlySummary?> getYearlySummary(int year) async {
    return await repository.getYearlySummary(year);
  }

  /// Gets all yearly summaries
  /// 
  /// Returns summaries for all years with archived data.
  /// Useful for multi-year trend analysis.
  /// 
  /// Returns:
  /// - [List<YearlySummary>] containing all yearly summaries
  /// 
  /// Example:
  /// ```dart
  /// final summaries = await getArchives.getAllYearlySummaries();
  /// for (final summary in summaries) {
  ///   print('${summary.year}: ${summary.totalAmount}');
  /// }
  /// ```
  Future<List<YearlySummary>> getAllYearlySummaries() async {
    return await repository.getAllYearlySummaries();
  }

  /// Checks if archive exists for a specific month
  /// 
  /// Returns true if an archive exists for the specified month.
  /// Useful for conditional logic and UI state management.
  /// 
  /// [year] Year to check
  /// [month] Month to check (1-12)
  /// 
  /// Returns:
  /// - [bool] true if archive exists, false otherwise
  /// 
  /// Example:
  /// ```dart
  /// final hasArchive = await getArchives.hasArchiveForMonth(2024, 3);
  /// if (hasArchive) {
  ///   // Show archive data
  /// } else {
  ///   // Show empty state
  /// }
  /// ```
  Future<bool> hasArchiveForMonth(int year, int month) async {
    return await repository.hasArchiveForMonth(year, month);
  }

  /// Gets list of all years with archived data
  /// 
  /// Returns sorted list of years that have at least one archive.
  /// Useful for year selection UI and navigation.
  /// 
  /// Returns:
  /// - [List<int>] years with data (newest first)
  /// 
  /// Example:
  /// ```dart
  /// final availableYears = await getArchives.getAvailableYears();
  /// // Use for dropdown or year selector
  /// ```
  Future<List<int>> getAvailableYears() async {
    return await repository.getAvailableYears();
  }

  /// Gets statistics about archived data
  /// 
  /// Returns comprehensive statistics about the archive system
  /// including totals, counts, and coverage information.
  /// 
  /// Returns:
  /// - [Map<String, dynamic>] containing archive statistics
  /// 
  /// Example:
  /// ```dart
  /// final stats = await getArchives.getArchiveStatistics();
  /// print('Total archived: ${stats['totalAmount']}');
  /// print('Months archived: ${stats['totalMonths']}');
  /// ```
  Future<Map<String, dynamic>> getArchiveStatistics() async {
    final allArchives = await repository.getAllArchives();
    final allSummaries = await repository.getAllYearlySummaries();
    
    final totalAmount = allArchives.fold<double>(0, (sum, a) => sum + a.totalAmount);
    final totalTransactions = allArchives.fold<int>(0, (sum, a) => sum + a.transactionCount);
    final availableYears = await repository.getAvailableYears();
    
    return {
      'totalMonths': allArchives.length,
      'totalYears': allSummaries.length,
      'totalAmount': totalAmount,
      'totalTransactions': totalTransactions,
      'availableYears': availableYears,
      'oldestYear': availableYears.isNotEmpty ? availableYears.last : null,
      'newestYear': availableYears.isNotEmpty ? availableYears.first : null,
      'averageMonthlySpending': allArchives.isNotEmpty ? totalAmount / allArchives.length : 0.0,
    };
  }
}