// Expense Archive Repository Interface
// 
// Defines the contract for expense archive operations in the domain layer.
// Provides methods for monthly reset functionality, historical data access,
// and yearly summary management following Clean Architecture principles.
// 
// Key Responsibilities:
// - Monthly expense archiving and reset operations
// - Historical data retrieval for analytics
// - Yearly summary management and calculation
// - Data integrity and consistency enforcement
// - Archive lifecycle management
// 
// Architecture:
// - Domain layer interface (framework-agnostic)
// - Implemented by data layer concrete classes
// - Used by use cases for business logic
// - Supports dependency inversion principle

import '../entities/expense.dart';
import '../entities/monthly_archive.dart';
import '../entities/yearly_summary.dart';

/// Repository interface for expense archive operations
/// 
/// Provides comprehensive archive management capabilities including
/// monthly resets, historical data access, and yearly analytics.
abstract class ExpenseArchiveRepository {
  // ==================== MONTHLY RESET OPERATIONS ====================

  /// Archives current month expenses and resets for new month
  /// 
  /// Takes all expenses from the current month, creates an archive,
  /// and clears the current expense list for a fresh start.
  /// 
  /// [currentExpenses] List of expenses to archive
  /// [year] Year of the month to archive
  /// [month] Month to archive (1-12)
  /// 
  /// Returns the created monthly archive
  Future<MonthlyArchive> archiveCurrentMonth({
    required List<Expense> currentExpenses,
    required int year,
    required int month,
  });

  /// Checks if monthly reset is needed
  /// 
  /// Determines if the current month has changed and expenses
  /// need to be archived and reset.
  /// 
  /// Returns true if reset is needed, false otherwise
  Future<bool> isMonthlyResetNeeded();

  /// Performs automatic monthly reset if needed
  /// 
  /// Checks if reset is needed and automatically archives
  /// previous month expenses if a new month has started.
  /// 
  /// [currentExpenses] Current expense list to potentially archive
  /// 
  /// Returns true if reset was performed, false otherwise
  Future<bool> performAutoResetIfNeeded(List<Expense> currentExpenses);

  // ==================== MONTHLY ARCHIVE OPERATIONS ====================

  /// Retrieves monthly archive for specific month
  /// 
  /// [year] Year of the archive
  /// [month] Month of the archive (1-12)
  /// 
  /// Returns monthly archive or null if not found
  Future<MonthlyArchive?> getMonthlyArchive(int year, int month);

  /// Retrieves all monthly archives for a specific year
  /// 
  /// [year] Year to get archives for
  /// 
  /// Returns list of monthly archives sorted by month
  Future<List<MonthlyArchive>> getYearlyArchives(int year);

  /// Retrieves all monthly archives across all years
  /// 
  /// Returns list of all archives sorted by year and month (newest first)
  Future<List<MonthlyArchive>> getAllArchives();

  /// Deletes a specific monthly archive
  /// 
  /// [year] Year of the archive to delete
  /// [month] Month of the archive to delete (1-12)
  /// 
  /// Also updates the yearly summary after deletion
  Future<void> deleteMonthlyArchive(int year, int month);

  /// Checks if archive exists for specific month
  /// 
  /// [year] Year to check
  /// [month] Month to check (1-12)
  /// 
  /// Returns true if archive exists, false otherwise
  Future<bool> hasArchiveForMonth(int year, int month);

  // ==================== YEARLY SUMMARY OPERATIONS ====================

  /// Retrieves yearly summary for specific year
  /// 
  /// [year] Year to get summary for
  /// 
  /// Returns yearly summary or null if not found
  Future<YearlySummary?> getYearlySummary(int year);

  /// Retrieves all yearly summaries
  /// 
  /// Returns list of yearly summaries sorted by year (newest first)
  Future<List<YearlySummary>> getAllYearlySummaries();

  /// Forces recalculation of yearly summary
  /// 
  /// Recalculates yearly summary from monthly archives
  /// and updates the stored summary.
  /// 
  /// [year] Year to recalculate summary for
  /// 
  /// Returns updated yearly summary
  Future<YearlySummary> recalculateYearlySummary(int year);

  /// Deletes yearly summary
  /// 
  /// [year] Year of summary to delete
  Future<void> deleteYearlySummary(int year);

  // ==================== ANALYTICS AND REPORTING ====================

  /// Gets all expenses from archives for analytics
  /// 
  /// Combines all archived expenses across all months and years
  /// for comprehensive analytics and reporting.
  /// 
  /// Returns list of all archived expenses
  Future<List<Expense>> getAllArchivedExpenses();

  /// Gets expenses from archives within date range
  /// 
  /// [startDate] Start of date range (inclusive)
  /// [endDate] End of date range (inclusive)
  /// 
  /// Returns expenses within the specified date range
  Future<List<Expense>> getArchivedExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Gets expenses from archives by category
  /// 
  /// [category] Category to filter by
  /// 
  /// Returns all archived expenses in the specified category
  Future<List<Expense>> getArchivedExpensesByCategory(String category);

  /// Gets monthly spending trend data
  /// 
  /// [numberOfMonths] Number of recent months to include
  /// 
  /// Returns map of month keys to spending amounts
  Future<Map<String, double>> getMonthlySpendingTrend(int numberOfMonths);

  /// Gets yearly spending trend data
  /// 
  /// [numberOfYears] Number of recent years to include
  /// 
  /// Returns map of years to total spending amounts
  Future<Map<int, double>> getYearlySpendingTrend(int numberOfYears);

  // ==================== UTILITY OPERATIONS ====================

  /// Gets list of all available years with data
  /// 
  /// Returns sorted list of years (newest first)
  Future<List<int>> getAvailableYears();

  /// Gets total archived amount across all time
  /// 
  /// Returns sum of all archived expenses
  Future<double> getTotalArchivedAmount();

  /// Gets total number of archived transactions
  /// 
  /// Returns count of all archived expenses
  Future<int> getTotalArchivedTransactions();

  /// Clears all archive data
  /// 
  /// Removes all monthly archives and yearly summaries.
  /// Use with caution as this operation is irreversible.
  Future<void> clearAllArchives();

  /// Exports archive data for backup
  /// 
  /// Returns JSON representation of all archive data
  Future<Map<String, dynamic>> exportArchiveData();

  /// Imports archive data from backup
  /// 
  /// [archiveData] JSON data to import
  /// 
  /// Returns true if import was successful
  Future<bool> importArchiveData(Map<String, dynamic> archiveData);
}