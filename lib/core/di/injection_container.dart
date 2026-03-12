import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/expenses/data/datasources/expense_local_datasource.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/add_expense.dart';
import '../../features/expenses/domain/usecases/delete_expense.dart';
import '../../features/expenses/domain/usecases/get_expenses.dart';
import '../../features/expenses/domain/usecases/update_expense.dart';
import '../../features/expenses/domain/usecases/export_expenses_to_csv.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initializeDependencies() async {
  // Register Hive adapters
  Hive.registerAdapter(ExpenseModelAdapter());
  
  // Hive boxes
  final expenseBox = await Hive.openBox('expenses');
  sl.registerSingleton<Box>(expenseBox);

  // Data sources
  sl.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => AddExpense(sl()));
  sl.registerLazySingleton(() => DeleteExpense(sl()));
  sl.registerLazySingleton(() => GetExpenses(sl()));
  sl.registerLazySingleton(() => UpdateExpense(sl()));
  sl.registerLazySingleton(() => ExportExpensesToCsv(sl()));
}
