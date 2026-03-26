import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_tracker_chart.dart';
import '../widgets/modern_expense_card.dart';
import '../widgets/stats_card.dart';
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
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [const Color(0xFF020617), const Color(0xFF0F172A)]
                  : [const Color(0xFFFAFAFA), const Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your expenses...'),
              ],
            ),
          ),
        ),
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
      child: RefreshIndicator(
        onRefresh: () async {
          ref.read(expenseProvider.notifier).loadExpenses();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header with slide animation
              SlideInAnimation.fromTop(
                delay: const Duration(milliseconds: 100),
                child: _buildWelcomeHeader(),
              ),
              
              const SizedBox(height: 24),
              
              // Show welcome card if no expenses exist
              if (expenseState.expenses.isEmpty) ...[
                SlideInAnimation.fromBottom(
                  delay: const Duration(milliseconds: 200),
                  child: WelcomeCard(
                    onAddExpense: () {
                      Navigator.push(
                        context,
                        FadeScalePageRoute(
                          child: const AddExpenseScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                // Monthly overview with animation
                SlideInAnimation.fromLeft(
                  delay: const Duration(milliseconds: 200),
                  child: _buildMonthlyOverview(totalAmount, currentMonth, monthlyExpenses),
                ),
                
                const SizedBox(height: 24),
                
                // Quick stats with staggered animation
                SlideInAnimation.fromRight(
                  delay: const Duration(milliseconds: 300),
                  child: _buildQuickStats(monthlyExpenses),
                ),
                
                const SizedBox(height: 24),
                
                // Category chart with fade animation
                SlideInAnimation.fromBottom(
                  delay: const Duration(milliseconds: 400),
                  child: _buildCategoryChart(monthlyExpenses),
                ),
                
                const SizedBox(height: 24),
                
                // Recent transactions with staggered list animation
                SlideInAnimation.fromBottom(
                  delay: const Duration(milliseconds: 500),
                  child: _buildRecentTransactions(monthlyExpenses),
                ),
              ],
              
              // Add some bottom padding for better scrolling
              const SizedBox(height: 100),
            ],
          ),
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
    return BounceAnimation(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
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
                PulseAnimation(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      monthlyExpenses.isEmpty 
                          ? Icons.account_balance_wallet_outlined
                          : Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Animated counter for total amount
            AnimatedCounter(
              initialValue: totalAmount,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
              prefix: '₹',
              duration: AnimationConstants.slow,
            ),
            
            const SizedBox(height: 16),
            
            // Monthly stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Transactions',
                    monthlyExpenses.length.toString(),
                    Icons.receipt_long_outlined,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Average',
                    monthlyExpenses.isEmpty 
                        ? '₹0'
                        : CurrencyFormatter.format(totalAmount / monthlyExpenses.length),
                    Icons.analytics_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
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

    final highestExpense = monthlyExpenses.isNotEmpty
        ? monthlyExpenses.reduce((a, b) => a.amount > b.amount ? a : b).amount
        : 0.0;

    return Row(
      children: [
        // Transactions count with staggered animation
        Expanded(
          child: StaggeredListAnimation(
            index: 0,
            delay: const Duration(milliseconds: 100),
            child: BounceAnimation(
              child: StatsCard(
                title: 'Transactions',
                initialValue: monthlyExpenses.length.toString(),
                icon: Icons.receipt_long_rounded,
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Average expense with staggered animation
        Expanded(
          child: StaggeredListAnimation(
            index: 1,
            delay: const Duration(milliseconds: 100),
            child: BounceAnimation(
              child: StatsCard(
                title: 'Average',
                initialValue: avgExpense.toStringAsFixed(0),
                icon: Icons.analytics_rounded,
                color: AppTheme.accentColor,
                isAmount: true,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Highest expense with staggered animation
        Expanded(
          child: StaggeredListAnimation(
            index: 2,
            delay: const Duration(milliseconds: 100),
            child: BounceAnimation(
              child: StatsCard(
                title: 'Highest',
                initialValue: highestExpense.toStringAsFixed(0),
                icon: Icons.trending_up_rounded,
                color: AppTheme.errorColor,
                isAmount: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart(List<Expense> monthlyExpenses) {
    return BounceAnimation(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with animation
            SlideInAnimation.fromLeft(
              delay: const Duration(milliseconds: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  PulseAnimation(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.pie_chart_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          
            // Compact category tracker for dashboard
            SlideInAnimation.fromBottom(
              delay: const Duration(milliseconds: 200),
              child: CompactCategoryTracker(
                expenses: monthlyExpenses,
                maxCategories: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(List<Expense> monthlyExpenses) {
    final recentExpenses = monthlyExpenses.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with animation
        SlideInAnimation.fromLeft(
          delay: const Duration(milliseconds: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
              if (monthlyExpenses.length > 5)
                BounceAnimation(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Navigate to full expense list
                  },
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        if (recentExpenses.isEmpty)
          SlideInAnimation.fromBottom(
            delay: const Duration(milliseconds: 200),
            child: _buildEmptyState(),
          )
        else
          // Staggered list animation for expense cards
          ...recentExpenses.asMap().entries.map((entry) {
            final index = entry.key;
            final expense = entry.value;
            
            return StaggeredListAnimation(
              index: index,
              delay: const Duration(milliseconds: 150),
              child: BounceAnimation(
                child: ModernExpenseCard(
                  expense: expense,
                  onTap: () => _navigateToDetails(expense),
                ),
                onTap: () => _navigateToDetails(expense),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.05),
                ]
              : [
                  AppTheme.primaryColor.withOpacity(0.05),
                  AppTheme.secondaryColor.withOpacity(0.02),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Animated icon
          PulseAnimation(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Start tracking your expenses',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Add your first expense to see insights and analytics',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Add expense button
          BounceAnimation(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Add Expense',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                FadeScalePageRoute(
                  child: const AddExpenseScreen(),
                ),
              );
            },
          ),
        ],
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