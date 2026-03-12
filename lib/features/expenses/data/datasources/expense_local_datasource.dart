import 'package:hive/hive.dart';
import '../models/expense_model.dart';

/// Local data source for expense operations using Hive
abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final Box box;

  ExpenseLocalDataSourceImpl(this.box);

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final expenses = box.values
        .map((e) => ExpenseModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await box.put(expense.id, expense.toJson());
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await box.put(expense.id, expense.toJson());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await box.delete(id);
  }
}
