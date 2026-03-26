import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/expense_provider.dart';
import '../widgets/modern_expense_card.dart';
import '../widgets/gradient_container.dart';
import 'expense_details_screen.dart';

/// Modern expense list screen with advanced filtering
class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen>
    with SingleTickerProviderStateMixin {
  String? selectedCategory;
  DateTimeRange? selectedDateRange;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    
    if (expenseState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final filteredExpenses = _getFilteredExpenses(expenseState.expenses);

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
      child: Column(
        children: [
          _buildHeader(filteredExpenses.length, expenseState.expenses.length),
          _buildSearchBar(),
          if (_showFilters) _buildFilters(),
          Expanded(
            child: filteredExpenses.isEmpty
                ? _buildEmptyState()
                : _buildExpenseList(filteredExpenses),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int filteredCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Expenses',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                filteredCount == totalCount
                    ? '$totalCount expenses'
                    : '$filteredCount of $totalCount expenses',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _showFilters
                      ? AppTheme.primaryColor
                      : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _toggleFilters,
                  icon: Icon(
                    Icons.tune_rounded,
                    color: _showFilters
                        ? Colors.white
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xFF64748B)),
                  ),
                ),
              ),
              if (_hasActiveFilters()) ...[
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _clearFilters,
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search expenses...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.5)
                : const Color(0xFF94A3B8),
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear_rounded),
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilters() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            child: GradientContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Category Filter
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...AppConstants.expenseCategories.map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(category),
                                size: 20,
                                color: _getCategoryColor(category),
                              ),
                              const SizedBox(width: 8),
                              Text(category),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date Range Filter
                  OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range_rounded),
                    label: Text(
                      selectedDateRange == null
                          ? 'Select Date Range'
                          : '${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpenseList(List filteredExpenses) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = filteredExpenses[index];
        return ModernExpenseCard(
          expense: expense,
          onTap: () => _navigateToDetails(expense),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GradientContainer(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _hasActiveFilters()
                  ? Icons.search_off_rounded
                  : Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.3)
                  : const Color(0xFF94A3B8),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              _hasActiveFilters()
                  ? 'No matching expenses'
                  : 'No expenses yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0xFF64748B),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              _hasActiveFilters()
                  ? 'Try adjusting your filters'
                  : 'Add your first expense to get started',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.5)
                    : const Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
            
            if (_hasActiveFilters()) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.flight_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFF97316);
      case 'Travel':
        return const Color(0xFF3B82F6);
      case 'Shopping':
        return const Color(0xFF8B5CF6);
      case 'Bills':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  List _getFilteredExpenses(List expenses) {
    var filtered = expenses;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = ref.read(expenseProvider.notifier).searchExpenses(searchQuery);
    }

    // Apply category filter
    if (selectedCategory != null) {
      filtered = filtered.where((e) => e.category == selectedCategory).toList();
    }

    // Apply date range filter
    if (selectedDateRange != null) {
      filtered = filtered.where((e) {
        return e.date.isAfter(selectedDateRange!.start.subtract(const Duration(days: 1))) &&
               e.date.isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  bool _hasActiveFilters() {
    return selectedCategory != null || 
           selectedDateRange != null || 
           searchQuery.isNotEmpty;
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
    
    if (_showFilters) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedDateRange = null;
      searchQuery = '';
      _searchController.clear();
    });
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