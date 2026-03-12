import '../entities/expense.dart';

/// Repository interface for expense operations
abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end);
  Future<List<Expense>> getExpensesByCategory(String category);
  Future<String> exportToCsv(List<Expense> expenses);
}
