import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/update_expense.dart';
import '../../domain/usecases/export_expenses_to_csv.dart';

/// State for expense list
class ExpenseState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;

  ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
  });

  ExpenseState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Expense provider for state management
class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final GetExpenses getExpenses;
  final AddExpense addExpense;
  final UpdateExpense updateExpense;
  final DeleteExpense deleteExpense;
  final ExportExpensesToCsv exportExpensesToCsv;

  ExpenseNotifier({
    required this.getExpenses,
    required this.addExpense,
    required this.updateExpense,
    required this.deleteExpense,
    required this.exportExpensesToCsv,
  }) : super(ExpenseState());

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final expenses = await getExpenses();
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> add(Expense expense) async {
    try {
      await addExpense(expense);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> update(Expense expense) async {
    try {
      await updateExpense(expense);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> delete(String id) async {
    try {
      await deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<String> exportToCsv() async {
    return await exportExpensesToCsv(state.expenses);
  }

  List<Expense> getExpensesByCategory(String category) {
    return state.expenses
        .where((expense) => expense.category == category)
        .toList();
  }

  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return state.expenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<Expense> searchExpenses(String query) {
    final lowerQuery = query.toLowerCase();
    return state.expenses.where((expense) {
      return expense.title.toLowerCase().contains(lowerQuery) ||
          expense.category.toLowerCase().contains(lowerQuery) ||
          (expense.notes?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}

/// Provider for expense notifier
final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>(
  (ref) => ExpenseNotifier(
    getExpenses: sl<GetExpenses>(),
    addExpense: sl<AddExpense>(),
    updateExpense: sl<UpdateExpense>(),
    deleteExpense: sl<DeleteExpense>(),
    exportExpensesToCsv: sl<ExportExpensesToCsv>(),
  ),
);
