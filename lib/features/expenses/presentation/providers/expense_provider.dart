/// Expense Management Provider
/// 
/// This file contains the state management logic for expense operations using Riverpod.
/// It follows the Clean Architecture pattern with clear separation of concerns.
/// 
/// Key Components:
/// - [ExpenseState]: Immutable state class for expense data
/// - [ExpenseNotifier]: State notifier for expense operations
/// - [expenseProvider]: Riverpod provider for dependency injection
/// 
/// Features:
/// - CRUD operations for expenses
/// - Search and filtering capabilities
/// - CSV export functionality
/// - PDF receipt generation
/// - Error handling and loading states
/// - Crashlytics integration for error tracking

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/update_expense.dart';
import '../../domain/usecases/export_expenses_to_csv.dart';
import '../../domain/usecases/generate_expense_receipt.dart';

/// Immutable state class for expense management
/// 
/// Represents the current state of the expense list with:
/// - [expenses]: List of all expenses
/// - [isLoading]: Loading state indicator
/// - [error]: Error message if any operation fails
/// 
/// This class follows the immutable state pattern for predictable state updates.
class ExpenseState {
  /// List of all expenses in the current state
  final List<Expense> expenses;
  
  /// Indicates if any async operation is in progress
  final bool isLoading;
  
  /// Error message from the last failed operation, null if no error
  final String? error;

  const ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
  });

  /// Creates a new state instance with updated values
  /// 
  /// Only provided parameters are updated, others retain current values.
  /// This ensures immutability and predictable state transitions.
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

/// State notifier for expense management operations
/// 
/// Handles all expense-related business logic and state updates.
/// Uses dependency injection for use cases following Clean Architecture.
/// 
/// Key Responsibilities:
/// - Managing expense CRUD operations
/// - Handling loading states and error management
/// - Providing search and filtering capabilities
/// - Coordinating with use cases for business logic
/// 
/// All methods are async and handle errors gracefully by updating the state.
class ExpenseNotifier extends StateNotifier<ExpenseState> {
  // Use case dependencies injected via constructor
  final GetExpenses getExpenses;
  final AddExpense addExpense;
  final UpdateExpense updateExpense;
  final DeleteExpense deleteExpense;
  final ExportExpensesToCsv exportExpensesToCsv;
  final GenerateExpenseReceipt generateExpenseReceipt;

  ExpenseNotifier({
    required this.getExpenses,
    required this.addExpense,
    required this.updateExpense,
    required this.deleteExpense,
    required this.exportExpensesToCsv,
    required this.generateExpenseReceipt,
  }) : super(const ExpenseState());

  /// Loads all expenses from the repository
  /// 
  /// Sets loading state to true, fetches expenses, and updates state.
  /// On error, sets error message and stops loading.
  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final expenses = await getExpenses();
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      // Log error to Crashlytics for monitoring
      await CrashlyticsService.logError(
        'Failed to load expenses',
        exception: e,
        stackTrace: StackTrace.current,
      );
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Adds a new expense to the repository
  /// 
  /// [expense] The expense entity to add
  /// Reloads the expense list after successful addition.
  Future<void> add(Expense expense) async {
    try {
      await addExpense(expense);
      
      // Log analytics event for expense addition
      await AnalyticsService.logExpenseAdded(
        amount: expense.amount,
        category: expense.category,
      );
      
      await loadExpenses();
    } catch (e) {
      // Log error to Crashlytics for monitoring
      await CrashlyticsService.logError(
        'Failed to add expense: ${expense.title}',
        exception: e,
        stackTrace: StackTrace.current,
      );
      state = state.copyWith(error: e.toString());
    }
  }

  /// Updates an existing expense in the repository
  /// 
  /// [expense] The expense entity with updated values
  /// Reloads the expense list after successful update.
  Future<void> update(Expense expense) async {
    try {
      // Find original expense for analytics comparison
      final originalExpense = state.expenses.firstWhere(
        (e) => e.id == expense.id,
        orElse: () => expense,
      );
      
      await updateExpense(expense);
      
      // Log analytics event for expense editing
      await AnalyticsService.logExpenseEdited(
        originalAmount: originalExpense.amount,
        newAmount: expense.amount,
        category: expense.category,
      );
      
      await loadExpenses();
    } catch (e) {
      // Log error to Crashlytics for monitoring
      await CrashlyticsService.logError(
        'Failed to update expense: ${expense.title}',
        exception: e,
        stackTrace: StackTrace.current,
      );
      state = state.copyWith(error: e.toString());
    }
  }

  /// Deletes an expense from the repository
  /// 
  /// [id] The unique identifier of the expense to delete
  /// Reloads the expense list after successful deletion.
  Future<void> delete(String id) async {
    try {
      // Find expense for analytics before deletion
      final expense = state.expenses.firstWhere((e) => e.id == id);
      
      await deleteExpense(id);
      
      // Log analytics event for expense deletion
      await AnalyticsService.logExpenseDeleted(
        amount: expense.amount,
        category: expense.category,
      );
      
      await loadExpenses();
    } catch (e) {
      // Log error to Crashlytics for monitoring
      await CrashlyticsService.logError(
        'Failed to delete expense with ID: $id',
        exception: e,
        stackTrace: StackTrace.current,
      );
      state = state.copyWith(error: e.toString());
    }
  }

  /// Exports all expenses to CSV format
  /// 
  /// Returns the file path of the generated CSV file.
  /// Uses the current expense list from state.
  Future<String> exportToCsv() async {
    final filePath = await exportExpensesToCsv(state.expenses);
    
    // Log analytics event for CSV export
    final totalAmount = state.expenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    
    await AnalyticsService.logCSVExported(
      expenseCount: state.expenses.length,
      totalAmount: totalAmount,
    );
    
    return filePath;
  }

  /// Generates a PDF receipt for a specific expense
  /// 
  /// [expense] The expense to generate receipt for
  /// Returns the file path of the generated PDF receipt.
  Future<String> generateReceiptPdf(Expense expense) async {
    final filePath = await generateExpenseReceipt.saveToDevice(expense);
    
    // Log analytics event for PDF generation
    await AnalyticsService.logPDFGenerated(
      amount: expense.amount,
      category: expense.category,
    );
    
    return filePath;
  }

  /// Filters expenses by category
  /// 
  /// [category] The category to filter by
  /// Returns a list of expenses matching the specified category.
  List<Expense> getExpensesByCategory(String category) {
    return state.expenses
        .where((expense) => expense.category == category)
        .toList();
  }

  /// Filters expenses by date range
  /// 
  /// [start] Start date (inclusive)
  /// [end] End date (inclusive)
  /// Returns expenses that fall within the specified date range.
  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return state.expenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Searches expenses by text query
  /// 
  /// [query] Search term to match against title, category, and notes
  /// Returns expenses that contain the query in any searchable field.
  /// Search is case-insensitive for better user experience.
  List<Expense> searchExpenses(String query) {
    final lowerQuery = query.toLowerCase();
    return state.expenses.where((expense) {
      return expense.title.toLowerCase().contains(lowerQuery) ||
          expense.category.toLowerCase().contains(lowerQuery) ||
          (expense.notes?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}

/// Riverpod provider for expense state management
/// 
/// Creates and provides the ExpenseNotifier with all required dependencies.
/// Uses the service locator (sl) to inject use case dependencies.
/// 
/// This provider can be watched by widgets to:
/// - Access current expense state
/// - Trigger expense operations
/// - React to state changes automatically
/// 
/// Usage example:
/// ```dart
/// final expenseState = ref.watch(expenseProvider);
/// final expenseNotifier = ref.read(expenseProvider.notifier);
/// ```
final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>(
  (ref) => ExpenseNotifier(
    getExpenses: sl<GetExpenses>(),
    addExpense: sl<AddExpense>(),
    updateExpense: sl<UpdateExpense>(),
    deleteExpense: sl<DeleteExpense>(),
    exportExpensesToCsv: sl<ExportExpensesToCsv>(),
    generateExpenseReceipt: sl<GenerateExpenseReceipt>(),
  ),
);
