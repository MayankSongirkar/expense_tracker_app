import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case for retrieving expenses
class GetExpenses {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  Future<List<Expense>> call() async {
    return await repository.getExpenses();
  }

  Future<List<Expense>> byDateRange(DateTime start, DateTime end) async {
    return await repository.getExpensesByDateRange(start, end);
  }

  Future<List<Expense>> byCategory(String category) async {
    return await repository.getExpensesByCategory(category);
  }
}
