import '../repositories/expense_repository.dart';

/// Use case for deleting an expense
class DeleteExpense {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteExpense(id);
  }
}
