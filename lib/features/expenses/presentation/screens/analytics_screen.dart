// Analytics Screen - Expense Insights and Visualizations
// 
// Provides comprehensive analytics and insights for user expenses including:
// - Overview statistics (total spending, monthly average)
// - Monthly spending trends with interactive charts
// - Category-wise expense breakdown with pie charts
// - Professional UI with gradient backgrounds and modern cards
// 
// Key Features:
// - Real-time data from Riverpod state management
// - Responsive design with proper loading and empty states
// - Material 3 design with consistent theming
// - Interactive charts using FL Chart library
// - Proper error handling and user feedback
// 
// Architecture:
// - ConsumerWidget for reactive state management
// - Modular widget composition for maintainability
// - Clean separation of UI and business logic
// - Reusable components for consistent design

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/gradient_container.dart';
import '../widgets/monthly_spending_chart.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/category_tracker_chart.dart';
import '../widgets/stats_card.dart';

/// Analytics screen widget for expense insights and visualizations
/// 
/// This screen provides users with comprehensive analytics about their spending
/// patterns, including statistical summaries, trend analysis, and category breakdowns.
/// 
/// The screen is built using ConsumerWidget to reactively respond to expense
/// state changes and automatically update the UI when new data is available.
/// 
/// Layout Structure:
/// 1. Header with title and description
/// 2. Overview statistics cards (total spending, monthly average)
/// 3. Monthly spending trend chart (12 months view)
/// 4. Category breakdown pie chart with legend
/// 
/// State Management:
/// - Watches expense provider for real-time data updates
/// - Handles loading states with progress indicators
/// - Displays appropriate empty states for new users
/// - Manages error states with user-friendly messages
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch expense state for reactive updates
    final expenseState = ref.watch(expenseProvider);
    
    // Show loading indicator while data is being fetched
    if (expenseState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calculate analytics data from current expenses
    final expenses = expenseState.expenses;
    final totalSpending = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final avgMonthlySpending = expenses.isNotEmpty 
        ? totalSpending / _getUniqueMonths(expenses)
        : 0.0;

    return Container(
      // Gradient background for visual appeal
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF020617), const Color(0xFF0F172A)]
              : [const Color(0xFFFAFAFA), const Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildOverviewStats(totalSpending, avgMonthlySpending, expenses.length),
            const SizedBox(height: 24),
            _buildMonthlyChart(context, expenses),
            const SizedBox(height: 24),
            _buildCategoryTracker(context, expenses),
            const SizedBox(height: 24),
            _buildCategoryAnalysis(context, expenses),
          ],
        ),
      ),
    );
  }

  /// Builds the analytics screen header section
  /// 
  /// Creates a professional header with title and descriptive subtitle.
  /// Uses theme-appropriate colors for both light and dark modes.
  /// 
  /// [context] Build context for accessing theme data
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Insights into your spending patterns',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the overview statistics section
  /// 
  /// Displays key metrics in a row of StatsCard widgets:
  /// - Total spending across all expenses
  /// - Monthly average spending calculation
  /// 
  /// [totalSpending] Sum of all expense amounts
  /// [avgMonthly] Average monthly spending amount
  /// [totalTransactions] Total number of expense records
  Widget _buildOverviewStats(double totalSpending, double avgMonthly, int totalTransactions) {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'Total Spending',
            initialValue: totalSpending == 0 ? '0' : totalSpending.toStringAsFixed(0),
            icon: Icons.account_balance_wallet_rounded,
            color: AppTheme.primaryColor,
            isAmount: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatsCard(
            title: 'Monthly Average',
            initialValue: avgMonthly == 0 ? '0' : avgMonthly.toStringAsFixed(0),
            icon: Icons.trending_up_rounded,
            color: AppTheme.secondaryColor,
            isAmount: true,
          ),
        ),
      ],
    );
  }

  /// Builds the monthly spending trend chart section
  /// 
  /// Creates a professional card containing the monthly spending chart
  /// with proper header, description, and chart component.
  /// 
  /// Features:
  /// - Gradient container for visual appeal
  /// - Header with icon and title
  /// - Descriptive subtitle
  /// - MonthlySpendingChart component for data visualization
  /// 
  /// [context] Build context for theme access
  /// [expenses] List of expenses to analyze for trends
  Widget _buildMonthlyChart(BuildContext context, List<Expense> expenses) {
    return GradientContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Spending Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Last 12 months spending overview',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          MonthlySpendingChart(expenses: expenses),
        ],
      ),
    );
  }

  /// Builds the enhanced category tracker section
  /// 
  /// Creates a comprehensive category tracking section with:
  /// - Interactive pie chart with touch feedback
  /// - Detailed category breakdown with progress bars
  /// - Transaction counts and percentages
  /// - Professional Material 3 design
  /// 
  /// [context] Build context for theme access
  /// [expenses] List of expenses to analyze by category
  Widget _buildCategoryTracker(BuildContext context, List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return CategoryTrackerChart(
      expenses: expenses,
      showBreakdown: true,
    );
  }

  /// Builds the category analysis section with pie chart
  /// 
  /// Creates a comprehensive category breakdown section featuring:
  /// - Professional header with icon
  /// - Empty state for users with no expenses
  /// - CategoryPieChart component for data visualization
  /// 
  /// The section adapts to show appropriate content based on whether
  /// the user has expenses or not, providing a good first-time user experience.
  /// 
  /// [context] Build context for theme access
  /// [expenses] List of expenses to analyze by category
  Widget _buildCategoryAnalysis(BuildContext context, List<Expense> expenses) {
    return GradientContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Spending distribution by category',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          // Show empty state or actual chart based on data availability
          if (expenses.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 48,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.3)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No category data available',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.5)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            )
          else
            CategoryPieChart(expenses: expenses),
        ],
      ),
    );
  }

  /// Calculates the number of unique months represented in the expense list
  /// 
  /// Used for computing monthly averages and analytics. Groups expenses
  /// by year-month combination to get accurate month counts.
  /// 
  /// [expenses] List of expenses to analyze
  /// Returns the number of unique months, minimum 1 to avoid division by zero
  int _getUniqueMonths(List<Expense> expenses) {
    final months = <String>{};
    for (final expense in expenses) {
      months.add('${expense.date.year}-${expense.date.month}');
    }
    return months.isEmpty ? 1 : months.length;
  }
}