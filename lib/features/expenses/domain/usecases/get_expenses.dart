// Use Case: Get Expenses
// 
// Domain layer use case for retrieving expense data with various filtering options.
// Provides a clean interface for the presentation layer to access expense data
// while maintaining separation from data layer implementation details.
// 
// Key Features:
// - Retrieve all expenses from the repository
// - Filter expenses by date range for period analysis
// - Filter expenses by category for targeted insights
// - Consistent error handling and data transformation
// 
// Architecture Benefits:
// - Encapsulates business logic for data retrieval
// - Provides multiple query methods for different use cases
// - Maintains clean separation between domain and data layers
// - Enables easy testing and mocking of data operations
// 
// Usage Examples:
// ```dart
// final getExpenses = GetExpenses(repository);
// 
// // Get all expenses
// final allExpenses = await getExpenses();
// 
// // Get expenses for a specific month
// final monthlyExpenses = await getExpenses.byDateRange(startDate, endDate);
// 
// // Get expenses for a specific category
// final foodExpenses = await getExpenses.byCategory('Food');
// ```

import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case for retrieving expenses with various filtering options
/// 
/// This use case provides multiple methods for querying expense data,
/// allowing the presentation layer to retrieve expenses based on different
/// criteria without knowing the underlying data storage implementation.
/// 
/// The use case acts as a facade over the repository, providing a clean
/// and consistent interface for all expense retrieval operations.
class GetExpenses {
  /// Repository dependency for data retrieval operations
  final ExpenseRepository repository;

  /// Creates a GetExpenses use case with the required repository dependency
  /// 
  /// [repository] The expense repository for data operations
  GetExpenses(this.repository);

  /// Retrieves all expenses from the repository
  /// 
  /// Returns a list of all expense records stored in the system,
  /// typically sorted by date in descending order (most recent first).
  /// 
  /// Returns:
  /// - [List<Expense>] containing all expenses, empty list if none exist
  /// 
  /// Throws:
  /// - [Exception] if the data retrieval operation fails
  /// 
  /// Example:
  /// ```dart
  /// final expenses = await getExpenses();
  /// debugPrint('Total expenses: ${expenses.length}');
  /// ```
  Future<List<Expense>> call() async {
    return await repository.getExpenses();
  }

  /// Retrieves expenses within a specific date range
  /// 
  /// Useful for generating reports, monthly summaries, or analyzing
  /// spending patterns over specific time periods.
  /// 
  /// [start] The start date of the range (inclusive)
  /// [end] The end date of the range (inclusive)
  /// 
  /// Returns:
  /// - [List<Expense>] containing expenses within the date range
  /// 
  /// Example:
  /// ```dart
  /// final startOfMonth = DateTime(2024, 3, 1);
  /// final endOfMonth = DateTime(2024, 3, 31);
  /// final monthlyExpenses = await getExpenses.byDateRange(startOfMonth, endOfMonth);
  /// ```
  Future<List<Expense>> byDateRange(DateTime start, DateTime end) async {
    return await repository.getExpensesByDateRange(start, end);
  }

  /// Retrieves expenses for a specific category
  /// 
  /// Enables category-wise analysis and filtering for budgeting
  /// and spending pattern analysis.
  /// 
  /// [category] The category to filter by (e.g., 'Food', 'Travel', 'Shopping')
  /// 
  /// Returns:
  /// - [List<Expense>] containing expenses in the specified category
  /// 
  /// Example:
  /// ```dart
  /// final foodExpenses = await getExpenses.byCategory('Food');
  /// final totalFoodSpending = foodExpenses.fold(0.0, (sum, e) => sum + e.amount);
  /// ```
  Future<List<Expense>> byCategory(String category) async {
    return await repository.getExpensesByCategory(category);
  }
}
