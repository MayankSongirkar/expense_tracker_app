import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/dummy_data.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/expense_card.dart';
import 'expense_details_screen.dart';

/// Dashboard screen showing expense overview
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expenseProvider.notifier).loadExpenses();
      _initializeDummyData();
    });
  }

  Future<void> _initializeDummyData() async {
    final expenseState = ref.read(expenseProvider);
    if (expenseState.expenses.isEmpty) {
      // Add dummy data for demonstration
      final dummyExpenses = DummyData.getDummyExpenses();
      for (final expense in dummyExpenses) {
        await ref.read(expenseProvider.notifier).add(expense);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    
    if (expenseState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentMonth = DateTime.now();
    final monthlyExpenses = expenseState.expenses.where((expense) {
      return DateHelper.isSameMonth(expense.date, currentMonth);
    }).toList();

    final totalAmount = monthlyExpenses.fold<double>(
      0, (sum, expense) => sum + expense.amount,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthlyOverview(totalAmount, currentMonth),
          const SizedBox(height: 24),
          _buildCategoryChart(monthlyExpenses),
          const SizedBox(height: 24),
          _buildRecentTransactions(monthlyExpenses),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverview(double totalAmount, DateTime currentMonth) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateHelper.formatDate(currentMonth, 'MMMM yyyy'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Total Expenses',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              CurrencyFormatter.format(totalAmount),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(List expenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            CategoryPieChart(expenses: expenses.cast<Expense>()),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(List expenses) {
    final recentExpenses = expenses.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (recentExpenses.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('No transactions this month')),
            ),
          )
        else
          ...recentExpenses.map((expense) => ExpenseCard(
            expense: expense,
            onTap: () => _navigateToDetails(expense),
          )),
      ],
    );
  }

  void _navigateToDetails(expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailsScreen(expense: expense),
      ),
    );
  }
}