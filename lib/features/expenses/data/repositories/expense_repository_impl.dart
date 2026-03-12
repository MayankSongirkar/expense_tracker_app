import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';

/// Implementation of expense repository
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl(this.localDataSource);

  @override
  Future<List<Expense>> getExpenses() async {
    final models = await localDataSource.getExpenses();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await localDataSource.addExpense(model);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await localDataSource.updateExpense(model);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await localDataSource.deleteExpense(id);
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    final expenses = await getExpenses();
    return expenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String category) async {
    final expenses = await getExpenses();
    return expenses.where((expense) => expense.category == category).toList();
  }

  @override
  Future<String> exportToCsv(List<Expense> expenses) async {
    List<List<dynamic>> rows = [
      ['Date', 'Title', 'Category', 'Amount', 'Notes']
    ];

    for (var expense in expenses) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(expense.date),
        expense.title,
        expense.category,
        expense.amount,
        expense.notes ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
