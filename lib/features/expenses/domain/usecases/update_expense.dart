import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case for updating an existing expense
class UpdateExpense {
  final ExpenseRepository repository;

  UpdateExpense(this.repository);

  Future<void> call(Expense expense) async {
    return await repository.updateExpense(expense);
  }
}
