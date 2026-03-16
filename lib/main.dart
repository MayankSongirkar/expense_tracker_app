/// Smart Expense Tracker - Main Application Entry Point
/// 
/// A comprehensive expense tracking application built with Flutter that provides:
/// - Clean Architecture with Domain-Driven Design
/// - Riverpod for state management
/// - Hive for local data persistence
/// - Material 3 design system
/// - PDF receipt generation
/// - Analytics and insights
/// 
/// Author: Smart Expense Tracker Team
/// Version: 1.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/expenses/data/models/expense_model.dart';
import 'features/expenses/data/models/monthly_archive_model.dart';
import 'features/expenses/data/models/yearly_summary_model.dart';
import 'features/expenses/presentation/providers/theme_provider.dart';
import 'features/expenses/presentation/screens/main_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';

/// Application entry point
/// 
/// Initializes all required services and dependencies before starting the app:
/// - Flutter widget binding
/// - Hive database with adapters
/// - Dependency injection container
/// - Riverpod provider scope
void main() async {
  // Ensure Flutter framework is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database for local storage
  await Hive.initFlutter();
  
  // Register custom Hive type adapters for data serialization
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(MonthlyArchiveModelAdapter());
  Hive.registerAdapter(YearlySummaryModelAdapter());
  
  // Initialize dependency injection container with all services
  await initializeDependencies();
  
  // Start the application with Riverpod provider scope
  runApp(const ProviderScope(child: MyApp()));
}

/// Root application widget
/// 
/// Configures the MaterialApp with:
/// - Theme management (light/dark mode)
/// - App title and branding
/// - Initial route determination
/// - Debug banner configuration
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme provider for reactive theme switching
    final isDarkMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Smart Expense Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Application initializer widget
/// 
/// Handles the initial app flow by:
/// - Checking onboarding completion status
/// - Showing loading indicator during initialization
/// - Routing to appropriate screen (onboarding or main app)
/// 
/// This ensures users see the onboarding flow only once and are
/// taken directly to the main app on subsequent launches.
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkOnboardingStatus(),
      builder: (context, snapshot) {
        // Show loading indicator while checking onboarding status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Route to appropriate screen based on onboarding status
        final isOnboardingCompleted = snapshot.data ?? false;
        return isOnboardingCompleted 
            ? const MainScreen() 
            : const OnboardingScreen();
      },
    );
  }

  /// Checks if user has completed the onboarding flow
  /// 
  /// Returns [true] if onboarding is completed, [false] otherwise.
  /// Uses Hive local storage to persist onboarding status.
  Future<bool> _checkOnboardingStatus() async {
    final box = await Hive.openBox('settings');
    return box.get('isOnboardingCompleted', defaultValue: false);
  }
}