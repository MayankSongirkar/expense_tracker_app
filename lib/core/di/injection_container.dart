import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../features/expenses/data/datasources/expense_local_datasource.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/add_expense.dart';
import '../../features/expenses/domain/usecases/delete_expense.dart';
import '../../features/expenses/domain/usecases/get_expenses.dart';
import '../../features/expenses/domain/usecases/update_expense.dart';
import '../../features/expenses/domain/usecases/export_expenses_to_csv.dart';
import '../../features/expenses/domain/usecases/generate_expense_receipt.dart';

// News module imports
import '../../features/news/data/datasources/news_remote_datasource.dart';
import '../../features/news/data/repositories/news_repository_impl.dart';
import '../../features/news/domain/repositories/news_repository.dart';
import '../../features/news/domain/usecases/get_latest_news.dart';
import '../../features/news/domain/usecases/get_crypto_news.dart';
import '../../features/news/domain/usecases/get_market_news.dart';
import '../../features/news/domain/usecases/get_news_sources.dart';
import '../../features/news/domain/usecases/search_news.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initializeDependencies() async {
  // External dependencies
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Hive boxes
  final expenseBox = await Hive.openBox<ExpenseModel>('expenses');
  sl.registerSingleton<Box<ExpenseModel>>(expenseBox);

  // Data sources
  sl.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(sl()),
  );
  
  // News data sources
  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSource(sl()),
  );

  // Repositories
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl()),
  );
  
  // News repositories
  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => AddExpense(sl()));
  sl.registerLazySingleton(() => DeleteExpense(sl()));
  sl.registerLazySingleton(() => GetExpenses(sl()));
  sl.registerLazySingleton(() => UpdateExpense(sl()));
  sl.registerLazySingleton(() => ExportExpensesToCsv(sl()));
  sl.registerLazySingleton(() => GenerateExpenseReceipt());
  
  // News use cases
  sl.registerLazySingleton(() => GetLatestNews(sl()));
  sl.registerLazySingleton(() => GetCryptoNews(sl()));
  sl.registerLazySingleton(() => GetMarketNews(sl()));
  sl.registerLazySingleton(() => GetNewsSources(sl()));
  sl.registerLazySingleton(() => SearchNews(sl()));
}
