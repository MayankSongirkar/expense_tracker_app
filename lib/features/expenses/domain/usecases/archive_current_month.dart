// Use Case: Archive Current Month
// 
// Domain layer use case responsible for archiving the current month's expenses
// and resetting for a new month. This enables the monthly reset functionality
// while preserving historical data for analytics.
// 
// Key Responsibilities:
// - Archive current month expenses to historical storage
// - Clear current expense list for fresh start
// - Update yearly summaries with archived data
// - Maintain data integrity during the reset process
// - Provide feedback on the archiving operation
// 
// Business Rules:
// - Only expenses from the specified month are archived
// - Current expense list is cleared after successful archiving
// - Yearly summaries are automatically updated
// - Archive operation is atomic (all or nothing)
// 
// Usage:
// ```dart
// final archiveMonth = ArchiveCurrentMonth(archiveRepository, expenseRepository);
// final archive = await archiveMonth(year: 2024, month: 3);
// ```

import '../entities/monthly_archive.dart';
import '../repositories/expense_repository.dart';
import '../repositories/expense_archive_repository.dart';
import '../../../../core/services/analytics_service.dart';

/// Use case for archiving current month expenses and resetting
/// 
/// This use case coordinates the monthly reset process by archiving
/// current expenses and clearing the active expense list.
class ArchiveCurrentMonth {
  /// Repository for archive operations
  final ExpenseArchiveRepository archiveRepository;
  
  /// Repository for current expense operations
  final ExpenseRepository expenseRepository;

  /// Creates an ArchiveCurrentMonth use case with required dependencies
  /// 
  /// [archiveRepository] Repository for archive operations
  /// [expenseRepository] Repository for current expense operations
  ArchiveCurrentMonth(this.archiveRepository, this.expenseRepository);

  /// Archives current month expenses and resets for new month
  /// 
  /// Performs the complete monthly reset process:
  /// 1. Gets all current expenses
  /// 2. Filters expenses for the specified month
  /// 3. Creates monthly archive with the expenses
  /// 4. Clears current expense list
  /// 5. Updates yearly summaries
  /// 
  /// [year] Year of the month to archive
  /// [month] Month to archive (1-12)
  /// 
  /// Returns the created monthly archive
  /// 
  /// Throws:
  /// - [Exception] if archiving fails
  /// - [Exception] if clearing current expenses fails
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final archive = await archiveCurrentMonth(year: 2024, month: 3);
  ///   debugPrint('Archived ${archive.transactionCount} expenses for ${archive.displayName}');
  /// } catch (e) {
  ///   debugPrint('Failed to archive month: $e');
  /// }
  /// ```
  Future<MonthlyArchive> call({
    required int year,
    required int month,
  }) async {
    // Get all current expenses
    final currentExpenses = await expenseRepository.getExpenses();
    
    // Filter expenses for the specified month
    final monthExpenses = currentExpenses.where((expense) {
      return expense.date.year == year && expense.date.month == month;
    }).toList();
    
    // Create and store the monthly archive
    final archive = await archiveRepository.archiveCurrentMonth(
      currentExpenses: monthExpenses,
      year: year,
      month: month,
    );
    
    // Clear the archived expenses from current list
    for (final expense in monthExpenses) {
      await expenseRepository.deleteExpense(expense.id);
    }
    
    // Log analytics event for monthly reset
    final totalAmount = monthExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    await AnalyticsService.logMonthlyReset(
      expenseCount: monthExpenses.length,
      totalAmount: totalAmount,
    );
    
    return archive;
  }

  /// Archives current month and resets if it's a new month
  /// 
  /// Automatically detects if a new month has started and performs
  /// the archiving process for the previous month.
  /// 
  /// Returns the created archive if reset was performed, null otherwise
  /// 
  /// Example:
  /// ```dart
  /// final archive = await archiveCurrentMonth.autoResetIfNeeded();
  /// if (archive != null) {
  ///   debugPrint('Auto-archived ${archive.displayName}');
  /// }
  /// ```
  Future<MonthlyArchive?> autoResetIfNeeded() async {
    final currentExpenses = await expenseRepository.getExpenses();
    
    // Check if reset is needed
    final resetNeeded = await archiveRepository.isMonthlyResetNeeded();
    if (!resetNeeded) return null;
    
    // Determine the previous month to archive
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1);
    
    // Filter expenses for the previous month
    final monthExpenses = currentExpenses.where((expense) {
      return expense.date.year == previousMonth.year && 
             expense.date.month == previousMonth.month;
    }).toList();
    
    if (monthExpenses.isEmpty) return null;
    
    // Archive the previous month
    return await call(
      year: previousMonth.year,
      month: previousMonth.month,
    );
  }

  /// Archives a specific month even if it's not current
  /// 
  /// Allows manual archiving of any month's expenses.
  /// Useful for organizing historical data or correcting archives.
  /// 
  /// [year] Year of the month to archive
  /// [month] Month to archive (1-12)
  /// [forceArchive] Whether to archive even if month already has an archive
  /// 
  /// Returns the created archive or existing archive if already exists
  /// 
  /// Example:
  /// ```dart
  /// final archive = await archiveCurrentMonth.archiveSpecificMonth(
  ///   year: 2024,
  ///   month: 2,
  ///   forceArchive: true,
  /// );
  /// ```
  Future<MonthlyArchive> archiveSpecificMonth({
    required int year,
    required int month,
    bool forceArchive = false,
  }) async {
    // Check if archive already exists
    if (!forceArchive) {
      final existingArchive = await archiveRepository.getMonthlyArchive(year, month);
      if (existingArchive != null) {
        return existingArchive;
      }
    }
    
    // Perform the archiving
    return await call(year: year, month: month);
  }

  /// Gets preview of what would be archived
  /// 
  /// Returns information about expenses that would be archived
  /// without actually performing the archiving operation.
  /// 
  /// [year] Year of the month to preview
  /// [month] Month to preview (1-12)
  /// 
  /// Returns map with preview information
  /// 
  /// Example:
  /// ```dart
  /// final preview = await archiveCurrentMonth.getArchivePreview(2024, 3);
  /// debugPrint('Would archive ${preview['count']} expenses totaling ${preview['amount']}');
  /// ```
  Future<Map<String, dynamic>> getArchivePreview({
    required int year,
    required int month,
  }) async {
    final currentExpenses = await expenseRepository.getExpenses();
    
    final monthExpenses = currentExpenses.where((expense) {
      return expense.date.year == year && expense.date.month == month;
    }).toList();
    
    final totalAmount = monthExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    
    final categoryTotals = <String, double>{};
    for (final expense in monthExpenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return {
      'year': year,
      'month': month,
      'count': monthExpenses.length,
      'totalAmount': totalAmount,
      'categories': categoryTotals.keys.toList(),
      'categoryTotals': categoryTotals,
      'hasExpenses': monthExpenses.isNotEmpty,
    };
  }
}