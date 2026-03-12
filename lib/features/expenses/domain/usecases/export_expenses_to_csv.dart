import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case for exporting expenses to CSV
class ExportExpensesToCsv {
  final ExpenseRepository repository;

  ExportExpensesToCsv(this.repository);

  Future<String> call(List<Expense> expenses) async {
    return await repository.exportToCsv(expenses);
  }
}
