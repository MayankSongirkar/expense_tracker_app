import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/modern_expense_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/gradient_container.dart';
import '../widgets/welcome_card.dart';
import 'expense_details_screen.dart';
import 'add_expense_screen.dart';

/// Modern dashboard screen with professional design
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    
    if (expenseState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final currentMonth = DateTime.now();
    final monthlyExpenses = expenseState.expenses.where((expense) {
      return DateHelper.isSameMonth(expense.date, currentMonth);
    }).toList();

    final totalAmount = monthlyExpenses.fold<double>(
      0, (sum, expense) => sum + expense.amount,
    );

    return Container(
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
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            
            // Show welcome card if no expenses exist
            if (expenseState.expenses.isEmpty) ...[
              WelcomeCard(
                onAddExpense: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddExpenseScreen(),
                    ),
                  );
                },
              ),
            ] else ...[
              _buildMonthlyOverview(totalAmount, currentMonth, monthlyExpenses),
              const SizedBox(height: 24),
              if (expenseState.expenses.isNotEmpty) ...[
                _buildQuickStats(monthlyExpenses),
                const SizedBox(height: 24),
                _buildCategoryChart(monthlyExpenses),
                const SizedBox(height: 24),
              ],
              _buildRecentTransactions(monthlyExpenses),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good ${_getGreeting()}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Here\'s your expense overview',
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildMonthlyOverview(double totalAmount, DateTime currentMonth, List<Expense> monthlyExpenses) {
    return AnimatedGradientContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateHelper.formatDate(currentMonth, 'MMMM yyyy'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total Expenses',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  monthlyExpenses.isEmpty 
                      ? Icons.account_balance_wallet_outlined
                      : Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            totalAmount == 0 
                ? '₹0.00' 
                : CurrencyFormatter.format(totalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            monthlyExpenses.isEmpty 
                ? 'No expenses this month yet'
                : '${monthlyExpenses.length} transaction${monthlyExpenses.length == 1 ? '' : 's'} this month',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<Expense> monthlyExpenses) {
    final avgExpense = monthlyExpenses.isNotEmpty
        ? monthlyExpenses.fold<double>(0, (sum, e) => sum + e.amount) / monthlyExpenses.length
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'Transactions',
            value: monthlyExpenses.length.toString(),
            icon: Icons.receipt_long_rounded,
            color: AppTheme.secondaryColor,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: StatsCard(
            title: 'Average',
            value: avgExpense.toStringAsFixed(0),
            icon: Icons.analytics_rounded,
            color: AppTheme.accentColor,
            isAmount: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart(List<Expense> monthlyExpenses) {
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          CategoryPieChart(expenses: monthlyExpenses),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(List<Expense> monthlyExpenses) {
    final recentExpenses = monthlyExpenses.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (monthlyExpenses.length > 5)
              TextButton(
                onPressed: () {
                  // Navigate to full expense list
                },
                child: const Text('View All'),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        if (recentExpenses.isEmpty)
          _buildEmptyState()
        else
          ...recentExpenses.map((expense) => ModernExpenseCard(
            expense: expense,
            onTap: () => _navigateToDetails(expense),
          )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GradientContainer(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start tracking your expenses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.9)
                    : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first expense to see insights and analytics',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add-expense');
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add First Expense'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailsScreen(expense: expense),
      ),
    );
  }
}