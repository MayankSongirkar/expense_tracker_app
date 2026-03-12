import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/category_pie_chart.dart';

/// Analytics screen showing expense charts and insights
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseState = ref.watch(expenseProvider);
    
    if (expenseState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (expenseState.expenses.isEmpty) {
      return const Center(
        child: Text('No expenses to analyze'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Spending',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MonthlyBarChart(expenses: expenseState.expenses),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Category Distribution',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CategoryPieChart(expenses: expenseState.expenses),
            ),
          ),
        ],
      ),
    );
  }
}